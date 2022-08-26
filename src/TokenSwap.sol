// contracts/TokenSwap.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "@uniswap-v3-periphery/interfaces/ISwapRouter.sol";
import "@uniswap-v3-periphery/libraries/TransferHelper.sol";
import "@uniswap-v3-core/interfaces/callback/IUniswapV3SwapCallback.sol";
import "@openzeppelin-contracts/token/ERC20/IERC20.sol";

contract TokenSwap {

    // Storage Variables
    address payable admin;
    ISwapRouter public immutable swapRouter;
    uint24 public constant poolFee = 3000;
    address public maticPolygonAddress = 0x0000000000000000000000000000000000001010;
    address public wethTokenPolygonAddress = 0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa;
    // IERC20 maticToken = IERC20(maticPolygonAddress);    // NOTE : Is this ERC20?
    IERC20 wethToken = IERC20(wethTokenPolygonAddress); // NOTE: we are currently assuming that all shorted assets are non-native

    constructor(ISwapRouter _swapRouter) {
        swapRouter = _swapRouter;
        admin = payable(msg.sender);
    } 

    // Swap from matic to weth
    function swapToWeth() public {
        // 1. Get contract's matic token balance
        uint maticBalance = address(this).balance;
        // 2. Approve Uniswap to spend our matic tokens
        TransferHelper.safeApprove(maticPolygonAddress, address(swapRouter), maticBalance);

        // 3. Construct swap params
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: maticPolygonAddress,
                tokenOut: wethTokenPolygonAddress,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: maticBalance,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // 4. Execute token swap.
        uint amountOut = swapRouter.exactInputSingle(params);
    }

    // // Swap from weth to matic
    // function swapToShortToken() private {
    //     // 1. Get contract's short token balance
    //     uint usdcBalance = IERC20(usdcPolygonAddress).balanceOf(address(this));
    //     // 2. Approve Uniswap to spend our short tokens
    //     TransferHelper.safeApprove(shortTokenPolygonAddress, address(swapRouter), usdcBalance);

    //     // 3. Construct swap params
    //     ISwapRouter.ExactInputSingleParams memory params =
    //         ISwapRouter.ExactInputSingleParams({
    //             tokenIn: usdcPolygonAddress,
    //             tokenOut: shortTokenPolygonAddress,
    //             fee: poolFee,
    //             recipient: msg.sender,
    //             deadline: block.timestamp,
    //             amountIn: usdcBalance,
    //             amountOutMinimum: 0,
    //             sqrtPriceLimitX96: 0
    //         });

    //     // 4. Execute token swap.
    //     uint amountOut = swapRouter.exactInputSingle(params);
    // }

    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
