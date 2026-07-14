# UniChatHooks 合约

UniChat / MIMA 社区经济的 Uniswap v4 Hook 集成模块。它把建群邀请、MIMA/USDT 流动性、Swap 活动和收益分账连接起来。

完整 Hardhat 实现在 `/Users/yoona/workspace/univ4-hooks`。这里保留面向 UniChat 的模块说明和一个很小的对接接口，保持和其它 `contract/<Module>` 目录一致，不把整套 Uniswap v4 代码搬进来。

## 目录

- [概述](#概述)
- [架构](#架构)
- [核心流程](#核心流程)
- [收益模型](#收益模型)
- [合约参考](#合约参考)
- [安全说明](#安全说明)

## 概述

UniChatHooks 把“加流动性”变成社区行为：

- 成员通过链上 share record 生成邀请关系。
- 被邀请人先把自己绑定到 inviter 和 group。
- MIMA/USDT 的 Uniswap v4 池被注册为 canonical Hook pool。
- LP 行为由 Hook 记录，并转发给收益管理器。
- 收益可按群主、邀请人、LP 进行拆分。

该模块主要面向 BSC 主网，因为 MIMA 的 Uniswap v4 池预计部署在 BSC。

## 架构

| 合约 | 职责 |
| --- | --- |
| `CommunityInviteBindingManager` | 创建 shareId，并把 invitee 永久绑定到 inviter/group/share。 |
| `CommunityPoolRegistry` | 保存 canonical MIMA/USDT Hook pool，并把群映射到该池。 |
| `MimaCommunityHook` | 校验已注册的 MIMA 池，记录 Swap，并转发 LP 回调。 |
| `CommunityHookRevenueManager` | 记录 LP 仓位，校验邀请绑定，并维护可领取收益。 |
| `CommunityHookLens` | 给前端聚合群、池、LP 仓位和收益读取。 |

```
社区分享
    -> 邀请绑定
    -> MIMA/USDT Hook 池
    -> LP 仓位
    -> 收益分账
    -> Claim
```

## 核心流程

1. 白名单成员创建分享，得到 `shareId`。
2. 被邀请人自己调用 `bindInvite` 完成绑定。
3. 管理员注册 MIMA Hook 和 canonical MIMA/USDT 池。
4. 被邀请人加 LP，并传入 Hook data：`(groupContract, lp, shareId)`。
5. Hook 校验池是否已注册，然后调用收益管理器。
6. 收益管理器校验邀请绑定、记录 LP 仓位，并可把 LP 加入群。
7. 收益 operator 分发奖励。
8. 用户按 token 领取累计收益。

## 收益模型

默认分账：

| 接收方 | 比例 |
| --- | ---: |
| 群主 | 20% |
| 邀请人 | 30% |
| LP | 50% |

如果没有邀请人，源项目中邀请人份额会回退给群主。

## 合约参考

`UniChatHooks.sol` 是本仓库里的轻量对接文件。它不引入 Uniswap v4 和 OpenZeppelin upgradeable 依赖，只记录 UniChat 应用需要关注的主要外部接口。

`univ4-hooks` 完整实现来源：

- `contracts/hooks/MimaCommunityHook.sol`
- `contracts/pool/CommunityPoolRegistry.sol`
- `contracts/invite/CommunityInviteBindingManager.sol`
- `contracts/revenue/CommunityHookRevenueManager.sol`
- `contracts/lens/CommunityHookLens.sol`

## 安全说明

- MIMA 交易应走 Hook pool 路径，不走普通 1inch 路由。
- 主网 Swap 必须使用非零 `amountOutMinimum`。
- LP 操作应在邀请绑定存在后再开放。
- Hook data 需要统一编码为 `(groupContract, lp, shareId)`。
- 关键 owner 和 operator 建议使用多签或同等级保护账户。
