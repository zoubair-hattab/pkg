import { ethers } from 'hardhat';
import { BigNumber, Contract, ContractTransaction } from 'ethers';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signer-with-address';

import * as expectEvent from '@balancer-labs/v2-helpers/src/test/expectEvent';
import { deploy, deployedAt } from '@balancer-labs/v2-helpers/src/contract';
import { bn, fp } from '@balancer-labs/v2-helpers/src/numbers';
import Vault from '@balancer-labs/v2-helpers/src/models/vault/Vault';
import { expect } from 'chai';
import { actionId } from '@balancer-labs/v2-helpers/src/models/misc/actions';
import { ANY_ADDRESS, ZERO_ADDRESS } from '@balancer-labs/v2-helpers/src/constants';

// This is used for the GaugeControllerMock only.
enum GaugeType {
  Ethereum = 0,
}

describe('GaugeRelativeWeightCap', () => {
  let vault: Vault;
  let gaugeController: Contract;
  let adaptor: Contract;
  let admin: SignerWithAddress, other: SignerWithAddress;
  let BAL: Contract, token: Contract;

  let liquidityGaugeImplementation: Contract;
  let liquidityGaugeFactory: Contract, stakelessGaugeFactory: Contract;

  let factory: Contract;

  const defaultRelativeWeightCap = fp(1);

  before('setup signers', async () => {
    [, admin, other] = await ethers.getSigners();
  });

  sharedBeforeEach('deploy authorizer', async () => {
    vault = await Vault.create({ admin });

    adaptor = await deploy('AuthorizerAdaptor', { args: [vault.address] });
    gaugeController = await deploy('MockGaugeController', { args: [ZERO_ADDRESS, adaptor.address] });

    // Type weight is ignored in the mock controller.
    await gaugeController.add_type('Ethereum', 0);
  });

  sharedBeforeEach('deploy token mocks', async () => {
    token = await deploy('TestBalancerToken', { args: [admin.address, 'Balancer-LP0', 'LP0'] });
    BAL = await deploy('TestBalancerToken', { args: [admin.address, 'Balancer', 'BAL'] });
  });

  sharedBeforeEach('deploy gauge implementation and factory', async () => {
    const balTokenAdmin = await deploy('MockBalancerTokenAdmin', { args: [vault.address, BAL.address] });
    const balMinter = await deploy('BalancerMinter', { args: [balTokenAdmin.address, gaugeController.address] });

    // We won't be using the code that requires the VotingEscrowDelegationProxy so we just use any address, since we
    // must initialize to a non-zero value.
    liquidityGaugeImplementation = await deploy('LiquidityGaugeV5', {
      args: [balMinter.address, ANY_ADDRESS, adaptor.address],
    });
    liquidityGaugeFactory = await deploy('LiquidityGaugeFactory', { args: [liquidityGaugeImplementation.address] });
    // SingleRecipient is the simplest StakelessGauge, so we test with that instead of using e.g. a mock (which would be
    // identical to SingleRecipient)
    stakelessGaugeFactory = await deploy('SingleRecipientGaugeFactory', { args: [balMinter.address] });
  });

  sharedBeforeEach('set up permissions', async () => {
    const action = await actionId(adaptor, 'setRelativeWeightCap', liquidityGaugeImplementation.interface);
    await vault.grantPermissionsGlobally([action], admin);
  });

  describe('LiquidityGaugeV5', () => {
    beforeEach('use liquidity gauge factory', () => {
      factory = liquidityGaugeFactory;
    });
    testRelativeWeightCapForGauge('LiquidityGaugeV5');
  });

  describe('StakelessGauge', () => {
    beforeEach('use stakeless gauge factory', () => {
      factory = stakelessGaugeFactory;
    });
    testRelativeWeightCapForGauge('SingleRecipientGauge');
  });

  function testRelativeWeightCapForGauge(contractName: string) {
    let gauge: Contract;
    async function setCap(relativeWeightCap: BigNumber): Promise<ContractTransaction> {
      const calldata = gauge.interface.encodeFunctionData('setRelativeWeightCap', [relativeWeightCap]);
      return adaptor.connect(admin).performAction(gauge.address, calldata);
    }

    describe('gauge creation', () => {
      context('when the initial cap value is too high', () => {
        const maxCap = fp(1.0);
        it('reverts', async () => {
          await expect(factory.create(token.address, maxCap.add(1))).to.be.revertedWith(
            'Relative weight cap exceeds allowed absolute maximum'
          );
        });
      });

      context('when the initial cap value is valid', () => {
        const initialCap = fp(0.75);
        it('emits a RelativeWeightCapChanged event', async () => {
          const tx = await factory.create(token.address, initialCap);
          expectCapChangedEvent(tx, initialCap);
        });

        it('sets the initial cap value', async () => {
          const gauge = await deployedAt(contractName, await deployGauge(factory, token.address, initialCap));
          expect(await gauge.getRelativeWeightCap()).to.be.eq(initialCap);
        });
      });
    });

    describe('setRelativeWeightCap', () => {
      const newCap = fp(0.3);
      function itSetsCap(cap: BigNumber) {
        it('sets relative weight cap', async () => {
          await setCap(cap);
          expect(await gauge.getRelativeWeightCap()).to.be.eq(cap);
        });

        it('emits an event', async () => {
          expectCapChangedEvent(await setCap(cap), cap);
        });
      }

      sharedBeforeEach('deploy gauge', async () => {
        gauge = await deployedAt(contractName, await deployGauge(factory, token.address));
      });

      context('when the caller is not authorized', () => {
        it('reverts', async () => {
          await expect(gauge.connect(other).setRelativeWeightCap(newCap)).to.be.reverted;
        });
      });

      context('when the caller is authorized', () => {
        const maxCap = fp(1.0);

        context('when the cap value is valid', () => {
          itSetsCap(newCap);

          itSetsCap(maxCap);

          itSetsCap(bn(0));
        });

        context('when the cap value is too high', () => {
          it('reverts', async () => {
            await expect(setCap(maxCap.add(1))).to.be.revertedWith(
              'Relative weight cap exceeds allowed absolute maximum'
            );
          });
        });
      });
    });

    describe('getCappedRelativeWeight', () => {
      const weight = fp(0.7);
      // The timestamp parameter is being ignored in the mock gauge controller.
      const anyTimestamp = bn(1234);

      sharedBeforeEach('deploy gauge', async () => {
        gauge = await deployedAt(contractName, await deployGauge(factory, token.address));
      });

      context('when the gauge is not added to the gauge controller', () => {
        it('returns 0', async () => {
          expect(await gauge.getCappedRelativeWeight(anyTimestamp)).to.be.eq(0);
        });
      });

      context('when the gauge is added to the gauge controller', () => {
        sharedBeforeEach('add gauge', async () => {
          await gaugeController.add_gauge(gauge.address, GaugeType.Ethereum);
          await gaugeController.setGaugeWeight(gauge.address, weight);
        });

        function capHasNoEffect(cap: BigNumber) {
          it('returns the weight uncapped', async () => {
            await setCap(cap);
            expect(await gauge.getCappedRelativeWeight(anyTimestamp)).to.be.eq(
              await gaugeController.gauge_relative_weight(gauge.address, anyTimestamp)
            );
          });
        }

        function capAffectsWeight(cap: BigNumber) {
          it('returns the cap', async () => {
            await setCap(cap);
            expect(await gauge.getCappedRelativeWeight(anyTimestamp)).to.be.eq(await gauge.getRelativeWeightCap());
          });
        }

        context('when cap equals the weight', () => {
          capHasNoEffect(weight);
        });

        context('when cap is above the weight', () => {
          capHasNoEffect(weight.add(1));
        });

        context('when the cap is below the weight', () => {
          capAffectsWeight(weight.sub(1));
        });

        context('when the cap is 0', () => {
          capAffectsWeight(bn(0));
        });
      });
    });
  }

  async function deployGauge(
    gaugeFactory: Contract,
    poolAddress: string,
    relativeWeightCap: BigNumber = defaultRelativeWeightCap
  ): Promise<string> {
    const tx = await gaugeFactory.create(poolAddress, relativeWeightCap);
    const event = expectEvent.inReceipt(await tx.wait(), 'GaugeCreated');

    return event.args.gauge;
  }

  async function expectCapChangedEvent(tx: ContractTransaction, newCap: BigNumber) {
    expectEvent.inIndirectReceipt(
      await tx.wait(),
      new ethers.utils.Interface(['event RelativeWeightCapChanged(uint256 new_relative_weight_cap)']),
      'RelativeWeightCapChanged',
      {
        new_relative_weight_cap: newCap,
      }
    );
  }
});
