// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
}

contract SimpleDEX {
    address public token0;
    address public token1;

    uint public reserve0;
    uint public reserve1;

    mapping(address => uint) public lpBalances;
    uint public totalLPSupply;

    event LiquidityAdded(address indexed provider, uint amount0, uint amount1, uint lpTokens);
    event LiquidityRemoved(address indexed provider, uint amount0, uint amount1, uint lpTokens);
    event Swapped(address indexed trader, address tokenIn, uint amountIn, address tokenOut, uint amountOut);

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
    }

    // Add liquidity to the pool
    function addLiquidity(uint amount0, uint amount1) external {
        require(amount0 > 0 && amount1 > 0, "Add amounts > 0");
        IERC20(token0).transferFrom(msg.sender, address(this), amount0);
        IERC20(token1).transferFrom(msg.sender, address(this), amount1);

        uint lpMinted;
        if (totalLPSupply == 0) {
            lpMinted = sqrt(amount0 * amount1);
        } else {
            lpMinted = min(
                (amount0 * totalLPSupply) / reserve0,
                (amount1 * totalLPSupply) / reserve1
            );
        }

        require(lpMinted > 0, "Insufficient LP minted");
        lpBalances[msg.sender] += lpMinted;
        totalLPSupply += lpMinted;

        reserve0 += amount0;
        reserve1 += amount1;
        emit LiquidityAdded(msg.sender, amount0, amount1, lpMinted);
    }

    // Remove liquidity from the pool
    function removeLiquidity(uint lpAmount) external {
        require(lpBalances[msg.sender] >= lpAmount, "Not enough LP");
        uint amount0 = (lpAmount * reserve0) / totalLPSupply;
        uint amount1 = (lpAmount * reserve1) / totalLPSupply;

        require(amount0 > 0 && amount1 > 0, "Amounts must be > 0");

        lpBalances[msg.sender] -= lpAmount;
        totalLPSupply -= lpAmount;

        reserve0 -= amount0;
        reserve1 -= amount1;

        IERC20(token0).transfer(msg.sender, amount0);
        IERC20(token1).transfer(msg.sender, amount1);
        emit LiquidityRemoved(msg.sender, amount0, amount1, lpAmount);
    }

    // Swap token0 <-> token1
    function swap(address tokenIn, uint amountIn) external {
        require(tokenIn == token0 || tokenIn == token1, "Invalid tokenIn");
        require(amountIn > 0, "Amount must be > 0");

        bool isToken0In = tokenIn == token0;
        (address tokenOut, uint reserveIn, uint reserveOut) = isToken0In
            ? (token1, reserve0, reserve1)
            : (token0, reserve1, reserve0);

        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        // 0.3% fee
        uint amountInWithFee = (amountIn * 997) / 1000;
        uint amountOut = (amountInWithFee * reserveOut) / (reserveIn + amountInWithFee);

        require(amountOut > 0, "Insufficient output amount");

        IERC20(tokenOut).transfer(msg.sender, amountOut);

        // Update reserves
        if (isToken0In) {
            reserve0 += amountIn;
            reserve1 -= amountOut;
        } else {
            reserve1 += amountIn;
            reserve0 -= amountOut;
        }
        emit Swapped(msg.sender, tokenIn, amountIn, tokenOut, amountOut);
    }

    // Utility functions
    function min(uint a, uint b) private pure returns (uint) {
        return a < b ? a : b;
    }

    function sqrt(uint y) private pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
