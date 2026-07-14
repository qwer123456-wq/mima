// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Minimal UniChat-facing interfaces for the MIMA Uniswap v4 Hook module.
/// @dev The full implementation stays in the univ4-hooks project; this file avoids
/// importing Uniswap v4 dependencies into the lightweight UniChat contract catalog.
interface IUniChatHooksCommunity {
    function owner() external view returns (address);
    function isInviterWhitelisted(address account) external view returns (bool);
    function claimJoin(address account) external;
}

interface IUniChatInviteBindingManager {
    struct InviteBinding {
        address community;
        address groupContract;
        address inviter;
        address groupOwner;
        uint256 shareId;
        uint8 admissionKind;
        uint256 boundAt;
        bool exists;
    }

    function recordShare(address community, address groupContract) external returns (uint256 shareId);

    function bindInvite(
        address community,
        address groupContract,
        uint256 shareId,
        address invitee,
        uint8 admissionKind
    ) external;

    function getInviteBinding(address groupContract, address invitee)
        external
        view
        returns (InviteBinding memory);

    function canShare(address groupContract, address sharer) external view returns (bool);
}

interface IUniChatHookPoolRegistry {
    struct HookPoolKey {
        address currency0;
        address currency1;
        uint24 fee;
        int24 tickSpacing;
        address hooks;
    }

    function getMimaPoolId() external view returns (bytes32 poolId);
    function getMimaPoolKey() external view returns (HookPoolKey memory poolKey);
    function getPoolKeyByGroup(address groupContract) external view returns (HookPoolKey memory poolKey);
    function isMimaPool(bytes32 poolId) external view returns (bool);
    function isGroupPool(bytes32 poolId, address groupContract) external view returns (bool);
}

interface IUniChatHookRevenueManager {
    struct LiquidityPosition {
        bytes32 poolId;
        address groupContract;
        address lp;
        address groupOwner;
        address inviter;
        uint256 shareId;
        uint256 liquidity;
        uint256 boundAt;
        bool exists;
    }

    function onHookAddLiquidity(bytes32 poolId, address lp, uint256 liquidityDelta, bytes calldata hookData)
        external;

    function onHookRemoveLiquidity(bytes32 poolId, address lp, uint256 liquidityDelta) external;

    function distributeRevenue(address groupContract, address lp, address rewardToken, uint256 amount) external;
    function claim(address rewardToken) external;
    function claimableByToken(address account, address rewardToken) external view returns (uint256);

    function getLpPosition(address groupContract, address lp)
        external
        view
        returns (LiquidityPosition memory);
}
