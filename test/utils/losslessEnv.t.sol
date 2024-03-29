// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import "lossless-v3/utils/LERC20.sol";
import "lossless-v3/utils/LosslessControllerV1.sol";
import "lossless-v3/LosslessControllerV3.sol";
import "lossless-v3/LosslessGovernance.sol";
import "lossless-v3/LosslessReporting.sol";
import "lossless-v3/LosslessStaking.sol";

import "../../src/Mocks/ERC20Mock.sol";
import "../../src/Mocks/ERC20OwnableMock.sol";
import "../../src/LosslessWrappedERC20.sol";
import "../../src/LosslessWrappedERC20Ownable.sol";

import "forge-std/Test.sol";

contract LosslessTestEnvironment is Test {
    LosslessControllerV1 private lssControllerV1;
    LosslessControllerV3 private lssControllerV3;
    TransparentUpgradeableProxy private transparentProxy;
    ProxyAdmin private proxyAdmin;
    LosslessControllerV3 public lssController;

    LosslessReporting public lssReporting;
    TransparentUpgradeableProxy private transparentProxyStak;
    ProxyAdmin private proxyAdminStak;

    LosslessStaking public lssStaking;
    TransparentUpgradeableProxy private transparentProxyRep;
    ProxyAdmin private proxyAdminRep;

    LosslessGovernance public lssGovernance;
    TransparentUpgradeableProxy private transparentProxyGov;
    ProxyAdmin private proxyAdminGov;

    LERC20 public lssToken;
    OwnableTestToken public testERC20;
    TestToken public adminlessTestERC20;

    LosslessWrappedERC20 public wLERC20a;
    LosslessWrappedERC20Ownable public wLERC20p;

    uint256 unwrappingDelay = 3 hours;

    address public dex = address(1099);

    address[] public whitelist = [address(this)];
    address[] public dexList = [dex];
    address[] public committeeMembers = [
        address(100),
        address(101),
        address(102),
        address(103),
        address(104)
    ];

    address public tokenOwner = address(800);

    address public reporter = address(200);
    address[] public stakers = [
        address(201),
        address(202),
        address(203),
        address(204),
        address(205)
    ];
    address maliciousActor = address(999);
    address retrievalReceiver = address(700);

    uint256 public totalSupply = 100000000000000000000;
    uint256 public mintAndBurnLimit = 99999999;
    uint256 public settlementPeriod = 10 minutes;
    uint256 public extraordinaryPeriod = 10 minutes;

    uint256 public mintPeriod = 10 minutes;
    uint256 public burnPeriod = 10 minutes;

    uint256 public stakingAmount = 10;
    uint256 public reportingAmount = 10;

    uint256 public reportLifetime = 1 days;

    uint256 public reporterReward = 2;
    uint256 public stakersReward = 2;
    uint256 public committeeReward = 2;
    uint256 public losslessReward = 10;

    uint256 public compensationPercentage = 10;

    uint256 public walletDispute = 7 days;

    uint256 public dexTransferTreshold = 5;
    uint256 public settlementTimelock = 10 minutes;

    uint256 public reportedAmount = 100000;

    function setUp() public {
        // Set up Controller
        setUpController();

        // Set up Tokens
        setUpTokens();

        // Set up Reporting
        setUpReporting();

        // Set up Staking
        setUpStaking();

        // Set up Governance
        setUpGovernance();

        // Set up Controller
        configureControllerVars();
    }

    /// ----- Helpers ------

    modifier withProtectedWrappedToken() {
        vm.startPrank(tokenOwner);
        wLERC20p = new LosslessWrappedERC20Ownable(
            testERC20,
            "Lossless Wrapped TEST",
            "wLTEST",
            tokenOwner,
            tokenOwner,
            1 hours,
            address(lssController),
            unwrappingDelay
        );

        assertEq(wLERC20p.symbol(), "wLTEST");

        testERC20.approve(address(wLERC20p), testERC20.balanceOf(tokenOwner));

        wLERC20p.depositFor(
            address(tokenOwner),
            (testERC20.balanceOf(tokenOwner) / 5) - 100
        );

        wLERC20p.transfer(address(maliciousActor), 1000);

        lssController.proposeNewSettlementPeriod(
            ILERC20(address(wLERC20p)),
            10 minutes
        );

        vm.warp(block.timestamp + 1 hours);

        lssController.executeNewSettlementPeriod(ILERC20(address(wLERC20p)));

        vm.stopPrank();

        _;
    }

    modifier withAdminlessProtectedWrappedToken() {
        vm.startPrank(tokenOwner);
        wLERC20a = new LosslessWrappedERC20(
            adminlessTestERC20,
            "Adminless Lossless Wrapped TEST",
            "wLTEST",
            address(lssController),
            unwrappingDelay
        );

        assertEq(wLERC20a.symbol(), "wLTEST");

        adminlessTestERC20.approve(
            address(wLERC20a),
            adminlessTestERC20.balanceOf(tokenOwner)
        );

        wLERC20a.depositFor(
            address(tokenOwner),
            (adminlessTestERC20.balanceOf(tokenOwner) / 5) - 100
        );

        wLERC20a.transfer(address(maliciousActor), 1000);

        vm.stopPrank();

        _;
    }

    modifier withReportsGenerated() {
        generateReport(address(wLERC20a), maliciousActor, reporter, wLERC20a);
        generateReport(address(wLERC20p), maliciousActor, reporter, wLERC20p);
        _;
    }

    modifier withReportsSolvedPositively() {
        solveReportPositively(1);
        solveReportPositively(2);

        vm.warp(block.timestamp + settlementPeriod + 1);
        _;
    }

    modifier withReportsSolvedNegatively() {
        solveReportNegatively(1);
        solveReportNegatively(2);

        vm.warp(block.timestamp + settlementPeriod + 1);
        _;
    }

    /// @notice Sets up Lossless Controller
    function setUpController() public {
        lssControllerV1 = new LosslessControllerV1();

        lssControllerV3 = new LosslessControllerV3();

        transparentProxy = new TransparentUpgradeableProxy(
            address(lssControllerV1),
            address(this),
            ""
        );

        proxyAdmin = new ProxyAdmin();

        transparentProxy.changeAdmin(address(proxyAdmin));

        LosslessControllerV1(address(transparentProxy)).initialize(
            address(this),
            address(this),
            address(this)
        );

        proxyAdmin.upgrade(transparentProxy, address(lssControllerV3));

        lssController = LosslessControllerV3(address(transparentProxy));
    }

    /// @notice Sets up Environment tokens
    function setUpTokens() public {
        lssToken = new LERC20(
            totalSupply,
            "Lossless Token",
            "LSS",
            address(this),
            address(this),
            1 days,
            address(lssController)
        );

        vm.startPrank(tokenOwner);
        testERC20 = new OwnableTestToken("Testing Token", "TEST", totalSupply);
        adminlessTestERC20 = new TestToken(
            "Testing Token",
            "TEST",
            totalSupply
        );
        vm.stopPrank();
    }

    /// @notice Sets up Lossless Reporting
    function setUpReporting() public {
        lssReporting = new LosslessReporting();

        transparentProxyRep = new TransparentUpgradeableProxy(
            address(lssReporting),
            address(this),
            ""
        );

        proxyAdminRep = new ProxyAdmin();

        transparentProxyRep.changeAdmin(address(proxyAdminRep));

        lssReporting.initialize(lssController);
        lssReporting.setReportLifetime(reportLifetime);
        lssReporting.setReportingAmount(reportingAmount);
        lssReporting.setStakingToken(lssToken);
        lssReporting.setReporterReward(reporterReward);
        lssReporting.setStakersReward(stakersReward);
        lssReporting.setCommitteeReward(committeeReward);
        lssReporting.setLosslessReward(losslessReward);
    }

    /// @notice Sets up Lossless Staking
    function setUpStaking() public {
        lssStaking = new LosslessStaking();

        transparentProxyStak = new TransparentUpgradeableProxy(
            address(lssStaking),
            address(this),
            ""
        );

        proxyAdminStak = new ProxyAdmin();

        transparentProxyStak.changeAdmin(address(proxyAdminStak));

        lssStaking.initialize(lssReporting, lssController, stakingAmount);
        lssStaking.setStakingToken(lssToken);
    }

    /// @notice Sets up Lossless Governance
    function setUpGovernance() public {
        lssGovernance = new LosslessGovernance();

        transparentProxyGov = new TransparentUpgradeableProxy(
            address(lssGovernance),
            address(this),
            ""
        );

        proxyAdminGov = new ProxyAdmin();

        transparentProxyGov.changeAdmin(address(proxyAdminGov));

        lssGovernance.initialize(
            lssReporting,
            lssController,
            lssStaking,
            walletDispute
        );
        lssGovernance.addCommitteeMembers(committeeMembers);
        lssGovernance.setCompensationAmount(compensationPercentage);

        lssReporting.setLosslessGovernance(lssGovernance);
        lssStaking.setLosslessGovernance(lssGovernance);
    }

    /// @notice Sets up Lossless Controller
    function configureControllerVars() public {
        lssController.setStakingContractAddress(lssStaking);
        lssController.setReportingContractAddress(lssReporting);
        lssController.setGovernanceContractAddress(lssGovernance);

        lssController.setWhitelist(whitelist, true);
        lssController.setDexList(dexList, true);

        lssController.setDexTransferThreshold(dexTransferTreshold);
        lssController.setSettlementTimeLock(settlementTimelock);
    }

    /// @notice Generate a report
    function generateReport(
        address reportedToken,
        address reportedAdr,
        address reporter,
        ERC20 fromToken
    ) public returns (uint256) {
        vm.assume(reportedAdr != address(lssToken));
        vm.assume(reportedAdr != address(lssReporting));
        vm.assume(reportedAdr != address(lssGovernance));
        vm.assume(reportedAdr != address(lssController));
        vm.assume(reportedAdr != address(lssStaking));
        lssToken.transfer(reporter, reportingAmount);
        vm.prank(tokenOwner);
        fromToken.transfer(reportedAdr, reportedAmount);
        vm.warp(block.timestamp + settlementPeriod + 1);
        vm.startPrank(reporter);
        lssToken.approve(address(lssReporting), reportingAmount);
        uint256 reportId = lssReporting.report(
            ILERC20(reportedToken),
            reportedAdr
        );
        vm.stopPrank();
        return reportId;
    }

    /// @notice Solve Report Positively
    function solveReportPositively(uint256 reportId) public {
        vm.prank(address(this));
        lssGovernance.losslessVote(reportId, true);

        for (uint8 i = 0; i < committeeMembers.length; i++) {
            vm.prank(committeeMembers[i]);
            lssGovernance.committeeMemberVote(reportId, true);
        }

        lssGovernance.resolveReport(reportId);
    }

    /// @notice Solve Report Negatively
    function solveReportNegatively(uint256 reportId) public {
        vm.prank(address(this));
        lssGovernance.losslessVote(reportId, false);

        for (uint8 i = 0; i < committeeMembers.length; i++) {
            vm.prank(committeeMembers[i]);
            lssGovernance.committeeMemberVote(reportId, false);
        }

        lssGovernance.resolveReport(reportId);
    }

    /// @notice Modular Report solving
    function solveReport(
        uint256 reportId,
        uint256 amountOfMembers,
        bool memberVote,
        bool losslessVote,
        bool adminVote
    ) public {
        require(
            amountOfMembers <= committeeMembers.length,
            "TEST: Not enough members"
        );

        vm.prank(address(this));
        lssGovernance.losslessVote(reportId, losslessVote);

        for (uint8 i = 0; i < amountOfMembers; i++) {
            vm.prank(committeeMembers[i]);
            lssGovernance.committeeMemberVote(reportId, memberVote);
        }

        (, , , , ILERC20 reportedToken, , ) = lssReporting.getReportInfo(
            reportId
        );

        if (address(reportedToken) != address(wLERC20a)) {
            vm.prank(reportedToken.admin());
            lssGovernance.tokenOwnersVote(reportId, adminVote);
        }

        lssGovernance.resolveReport(reportId);
    }

    /// @notice Stake on a report
    function stakeOnReport(
        uint256 reportId,
        uint256 amountOfStakers,
        uint256 skipTime
    ) public {
        require(amountOfStakers <= stakers.length, "TEST: Not enough stakers");

        for (uint8 i = 0; i < amountOfStakers; i++) {
            vm.prank(address(this));
            lssToken.transfer(stakers[i], stakingAmount);
            vm.startPrank(stakers[i]);
            lssToken.approve(address(lssStaking), stakingAmount);
            vm.warp(settlementPeriod + 5);
            lssStaking.stake(reportId);
            vm.warp(skipTime);
            vm.stopPrank();
        }
    }

    function claimStakeOnReport(uint256 reportId) public {
        for (uint8 i = 0; i < stakers.length; i++) {
            vm.startPrank(stakers[i]);
            lssStaking.stakerClaim(reportId);
            vm.stopPrank();
        }
    }

    /// @notice Proposes wallet and retrieves funds
    function retrieveFundsForReport(
        uint256 reportId,
        bool dispute,
        address retrieveTo
    ) public {
        vm.prank(address(this));
        lssGovernance.proposeWallet(reportId, retrieveTo);

        if (dispute) {
            for (uint256 i = 0; i < committeeMembers.length; i++) {
                vm.prank(committeeMembers[i]);
                lssGovernance.rejectWallet(reportId);
            }

            vm.prank(tokenOwner);
            lssGovernance.rejectWallet(reportId);

            vm.prank(address(this));
            lssGovernance.rejectWallet(reportId);
        }

        vm.warp(block.timestamp + walletDispute + 1 hours);
        vm.prank(retrieveTo);
        lssGovernance.retrieveFunds(reportId);
    }
}
