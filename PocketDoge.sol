/**
 *Submitted for verification at BscScan.com on 2021-08-18
*/

/**
 *Submitted for verification at BscScan.com on 2021-07-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@nomiclabs/buidler/console.sol";

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface DividendPayingTokenOptionalInterface {
    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function withdrawableDividendOf(address _owner)
        external
        view
        returns (uint256);

    /// @notice View the amount of dividend in wei that an address has withdrawn.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has withdrawn.
    function withdrawnDividendOf(address _owner)
        external
        view
        returns (uint256);

    /// @notice View the amount of dividend in wei that an address has earned in total.
    /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has earned in total.
    function accumulativeDividendOf(address _owner)
        external
        view
        returns (uint256);
}

interface DividendPayingTokenInterface {
    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function dividendOf(address _owner) external view returns (uint256);

    /// @notice Distributes ether to token holders as dividends.
    /// @dev SHOULD distribute the paid ether to token holders as dividends.
    ///  SHOULD NOT directly transfer ether to token holders in this function.
    ///  MUST emit a `DividendsDistributed` event when the amount of distributed ether is greater than 0.
    function distributeDividends() external payable;

    /// @notice Withdraws the ether distributed to the sender.
    /// @dev SHOULD transfer `dividendOf(msg.sender)` wei to `msg.sender`, and `dividendOf(msg.sender)` SHOULD be 0 after the transfer.
    ///  MUST emit a `DividendWithdrawn` event if the amount of ether transferred is greater than 0.
    function withdrawDividend() external;

    /// @dev This event MUST emit when ether is distributed to token holders.
    /// @param from The address which sends ether to this contract.
    /// @param weiAmount The amount of distributed ether in wei.
    event DividendsDistributed(address indexed from, uint256 weiAmount);

    /// @dev This event MUST emit when an address withdraws their dividend.
    /// @param to The address which withdraws ether from this contract.
    /// @param weiAmount The amount of withdrawn ether in wei.
    event DividendWithdrawn(address indexed to, uint256 weiAmount);
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }

    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract DividendPayingToken is
    ERC20,
    DividendPayingTokenInterface,
    DividendPayingTokenOptionalInterface
{
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    // With `magnitude`, we can properly distribute dividends even if the amount of received ether is small.
    // For more discussion about choosing the value of `magnitude`,
    //  see https://github.com/ethereum/EIPs/issues/1726#issuecomment-472352728
    uint256 internal constant magnitude = 2**128;

    uint256 internal magnifiedDividendPerShare;

    // About dividendCorrection:
    // If the token balance of a `_user` is never changed, the dividend of `_user` can be computed with:
    //   `dividendOf(_user) = dividendPerShare * balanceOf(_user)`.
    // When `balanceOf(_user)` is changed (via minting/burning/transferring tokens),
    //   `dividendOf(_user)` should not be changed,
    //   but the computed value of `dividendPerShare * balanceOf(_user)` is changed.
    // To keep the `dividendOf(_user)` unchanged, we add a correction term:
    //   `dividendOf(_user) = dividendPerShare * balanceOf(_user) + dividendCorrectionOf(_user)`,
    //   where `dividendCorrectionOf(_user)` is updated whenever `balanceOf(_user)` is changed:
    //   `dividendCorrectionOf(_user) = dividendPerShare * (old balanceOf(_user)) - (new balanceOf(_user))`.
    // So now `dividendOf(_user)` returns the same value before and after `balanceOf(_user)` is changed.
    mapping(address => int256) internal magnifiedDividendCorrections;
    mapping(address => uint256) internal withdrawnDividends;

    uint256 public totalDividendsDistributed;

    constructor(string memory _name, string memory _symbol)
        ERC20(_name, _symbol)
    {}

    /// @dev Distributes dividends whenever ether is paid to this contract.
    receive() external payable {
        distributeDividends();
    }

    /// @notice Distributes ether to token holders as dividends.
    /// @dev It reverts if the total supply of tokens is 0.
    /// It emits the `DividendsDistributed` event if the amount of received ether is greater than 0.
    /// About undistributed ether:
    ///   In each distribution, there is a small amount of ether not distributed,
    ///     the magnified amount of which is
    ///     `(msg.value * magnitude) % totalSupply()`.
    ///   With a well-chosen `magnitude`, the amount of undistributed ether
    ///     (de-magnified) in a distribution can be less than 1 wei.
    ///   We can actually keep track of the undistributed ether in a distribution
    ///     and try to distribute it in the next distribution,
    ///     but keeping track of such data on-chain costs much more than
    ///     the saved ether, so we don't do that.
    function distributeDividends() public payable override {
        require(totalSupply() > 0);

        if (msg.value > 0) {
            magnifiedDividendPerShare = magnifiedDividendPerShare.add(
                (msg.value).mul(magnitude) / totalSupply()
            );
            emit DividendsDistributed(msg.sender, msg.value);

            totalDividendsDistributed = totalDividendsDistributed.add(
                msg.value
            );
        }
    }

    /// @notice Withdraws the ether distributed to the sender.
    /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn ether is greater than 0.
    function withdrawDividend() public virtual override {
        _withdrawDividendOfUser(payable(msg.sender));
    }

    /// @notice Withdraws the ether distributed to the sender.
    /// @dev It emits a `DividendWithdrawn` event if the amount of withdrawn ether is greater than 0.
    function _withdrawDividendOfUser(address payable user)
        internal
        virtual
        returns (uint256)
    {
        uint256 _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] = withdrawnDividends[user].add(
                _withdrawableDividend
            );
            emit DividendWithdrawn(user, _withdrawableDividend);
            (bool success, ) = user.call{
                value: _withdrawableDividend,
                gas: 3000
            }("");

            if (!success) {
                withdrawnDividends[user] = withdrawnDividends[user].sub(
                    _withdrawableDividend
                );
                return 0;
            }

            return _withdrawableDividend;
        }

        return 0;
    }

    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function dividendOf(address _owner) public view override returns (uint256) {
        return withdrawableDividendOf(_owner);
    }

    /// @notice View the amount of dividend in wei that an address can withdraw.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` can withdraw.
    function withdrawableDividendOf(address _owner)
        public
        view
        override
        returns (uint256)
    {
        return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
    }

    /// @notice View the amount of dividend in wei that an address has withdrawn.
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has withdrawn.
    function withdrawnDividendOf(address _owner)
        public
        view
        override
        returns (uint256)
    {
        return withdrawnDividends[_owner];
    }

    /// @notice View the amount of dividend in wei that an address has earned in total.
    /// @dev accumulativeDividendOf(_owner) = withdrawableDividendOf(_owner) + withdrawnDividendOf(_owner)
    /// = (magnifiedDividendPerShare * balanceOf(_owner) + magnifiedDividendCorrections[_owner]) / magnitude
    /// @param _owner The address of a token holder.
    /// @return The amount of dividend in wei that `_owner` has earned in total.
    function accumulativeDividendOf(address _owner)
        public
        view
        override
        returns (uint256)
    {
        return
            magnifiedDividendPerShare
                .mul(balanceOf(_owner))
                .toInt256Safe()
                .add(magnifiedDividendCorrections[_owner])
                .toUint256Safe() / magnitude;
    }

    /// @dev Internal function that transfer tokens from one address to another.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param from The address to transfer from.
    /// @param to The address to transfer to.
    /// @param value The amount to be transferred.
    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        require(false);

        int256 _magCorrection = magnifiedDividendPerShare
            .mul(value)
            .toInt256Safe();
        magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from]
            .add(_magCorrection);
        magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(
            _magCorrection
        );
    }

    /// @dev Internal function that mints tokens to an account.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param account The account that will receive the created tokens.
    /// @param value The amount that will be created.
    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[
            account
        ].sub((magnifiedDividendPerShare.mul(value)).toInt256Safe());
    }

    /// @dev Internal function that burns an amount of the token of a given account.
    /// Update magnifiedDividendCorrections to keep dividends unchanged.
    /// @param account The account whose tokens will be burnt.
    /// @param value The amount that will be burnt.
    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[
            account
        ].add((magnifiedDividendPerShare.mul(value)).toInt256Safe());
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = balanceOf(account);

        if (newBalance > currentBalance) {
            uint256 mintAmount = newBalance.sub(currentBalance);
            _mint(account, mintAmount);
        } else if (newBalance < currentBalance) {
            uint256 burnAmount = currentBalance.sub(newBalance);
            _burn(account, burnAmount);
        }
    }
}

contract PocketDoge is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;

    address public uniswapV2Pair;

    bool private swapping;
    bool private stakingEnabled = true;
    bool public tradingEnabled = false;

    uint256 public sellAmount = 0;
    uint256 public buyAmount = 0;

    uint256 private totalSellFees;
    uint256 private totalBuyFees;

    PocketDogeDividendTracker public dividendTracker;

    address public liquidityWallet;

    address payable public developmentWallet;
    address payable public marketingWallet;

    // LAUNCH Determine sane values
    uint256 public maxSellTransactionAmount = 0;
    uint256 public swapTokensAtAmount = 200000000 * (10**18);

    uint256 public sellBNBRewardsFee;
    uint256 public sellDevFees;
    uint256 public sellMarketingFees;
    uint256 public sellLiquidityFee;
    uint256 public buyDevFees;
    uint256 public buyMarketingFees;
    uint256 public buyLiquidityFee;
    uint256 public buyBNBRewardsFee;

    bool public swapAndLiquifyEnabled = true;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;

    // exlcude from fees and max transaction amount
    mapping(address => bool) private _isExcludedFromFees;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping(address => bool) public automatedMarketMakerPairs;

    mapping(address => uint256) public stakingBonus;
    mapping(address => uint256) public stakingUntilDate;
    mapping(uint256 => uint256) public stakingAmounts;

    mapping(address => bool) private canTransferBeforeTradingIsEnabled;

    // LAUNCH Impplement access control modifiers

    event EnableAccountStaking(address indexed account, uint256 duration);
    event UpdateStakingAmounts(uint256 duration, uint256 amount);

    event EnableSwapAndLiquify(bool enabled);
    event EnableStaking(bool enabled);

    event SetPreSaleWallet(address wallet);

    event UpdateDividendTracker(
        address indexed newAddress,
        address indexed oldAddress
    );

    event UpdateUniswapV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );

    event TradingEnabled();

    event UpdateFees(
        uint256 sellDevFees,
        uint256 sellMarketingFees,
        uint256 sellLiquidityFee,
        uint256 sellBNBRewardsFee,
        uint256 buyDevFees,
        uint256 buyMarketingFees,
        uint256 buyLiquidityFee,
        uint256 buyBNBRewardsFee
    );

    event Airdrop(address holder, uint256 amount);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(
        address indexed newLiquidityWallet,
        address indexed oldLiquidityWallet
    );

    event GasForProcessingUpdated(
        uint256 indexed newValue,
        uint256 indexed oldValue
    );

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SendDividends(uint256 amount, uint256 opAmount, bool success);

    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );

    event UpdatePayoutToken(address account, address token);
    event UpdateAllowTokens(address token, bool allow);

    constructor(
        address development,
        address marketing,
        address _liquidityWallet,
        address router,
        string memory name,
        string memory ticker,
        string memory tracker,
        string memory trackerTicker
    ) ERC20(name, ticker) {
        developmentWallet = payable(development);
        marketingWallet = payable(marketing);

        buyDevFees = 0;
        sellDevFees = 0;

        buyMarketingFees = 0;
        sellMarketingFees = 0;

        buyLiquidityFee = 0;
        sellLiquidityFee = 0;

        buyBNBRewardsFee = 0;
        sellBNBRewardsFee = 0;

        totalBuyFees = buyBNBRewardsFee
            .add(buyLiquidityFee)
            .add(buyDevFees)
            .add(buyMarketingFees);
        totalSellFees = sellBNBRewardsFee
            .add(sellLiquidityFee)
            .add(sellDevFees)
            .add(sellMarketingFees);

        dividendTracker = new PocketDogeDividendTracker(
            payable(this),
            router,
            tracker,
            trackerTicker
        );

        liquidityWallet = _liquidityWallet;

        uniswapV2Router = IUniswapV2Router02(router);
        
        console.log("uniswapV2Router", uniswapV2Router);

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );

        _setAutomatedMarketMakerPair(uniswapV2Pair, true);

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(
            0x000000000000000000000000000000000000dEaD
        );

        dividendTracker.excludedFromDividends(address(0));
        dividendTracker.excludeFromDividends(router);

        dividendTracker.excludeFromDividends(developmentWallet);
        dividendTracker.excludeFromDividends(marketingWallet);
        dividendTracker.excludeFromDividends(liquidityWallet);

        // exclude from paying fees or having max transaction amount
        _isExcludedFromFees[liquidityWallet] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[address(dividendTracker)] = true;

        canTransferBeforeTradingIsEnabled[owner()] = true;
        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */

        uint256 totalTokenSupply = (10**11) * (10**18);
        _mint(owner(), totalTokenSupply / 2);
        _mint(liquidityWallet, totalTokenSupply / 2);
    }

    /*
    }
        TOTAL SUPPLY OF PDOGE:
        
                 ___   _____   _____     _     _ _ _  _             
                (___) (_____) (_____)   | |   (_) | |(_)            
                   _  _  __ _ _  __ _   | |__  _| | | _  ___  ____  
                  | || |/ /| | |/ /| |  |  _ \| | | || |/ _ \|  _ \ 
                 _| ||   /_| |   /_| |  | |_) ) | | || | |_| | | | |
                (_____)_____/ \_____/   |____/|_|\_)_)_|\___/|_| |_|
                                                                    
     */

    function primeForLaunch() public onlyOwner {
        tradingEnabled = false;
        excludeFromFees(owner(), true);
        updateAllowTokens(address(this), true);
        canTransferBeforeTradingIsEnabled[owner()] = true;
        canTransferBeforeTradingIsEnabled[address(this)] = true;
        updateAllowTokens(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82, true); // CAKE
        updateAllowTokens(0x3EE2200Efb3400fAbB9AacF31297cBdD1d435D47, true); // ADA
        updateAllowTokens(0x2170Ed0880ac9A755fd29B2688956BD959F933F8, true); // ETH
        updateAllowTokens(0x55d398326f99059fF775485246999027B3197955, true); // USDT
        updateAllowTokens(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56, true); // BUSD
        distribute();
    }

    function distribute() private onlyOwner {
        //ouint256 l p, a, c, m, d; // = splitSupply();
    }

    function splitSupply()
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 onePercent = totalSupply().div(100);
        uint256 liq = onePercent.mul(50);
        uint256 pre = onePercent.mul(34);
        uint256 air = onePercent.mul(5);
        uint256 cor = onePercent.mul(5);
        uint256 mkt = onePercent.mul(4);
        uint256 dev = onePercent.mul(2);
        return (liq, pre, air, cor, mkt, dev);
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    receive() external payable {}

    function updateStakingAmounts(uint256 duration, uint256 bonus)
        public
        onlyOwner
    {
        require(stakingAmounts[duration] != bonus);
        require(bonus <= 100, "Staking bonus can't exceed 100");

        stakingAmounts[duration] = bonus;
        emit UpdateStakingAmounts(duration, bonus);
    }

    function enableTrading() external onlyOwner {
        require(!tradingEnabled);
        updateFees(1, 1, 2, 2, 4, 4, 8, 12);
        tradingEnabled = true;
        emit TradingEnabled();
    }

    function setPresaleWallet(address wallet) external onlyOwner {
        canTransferBeforeTradingIsEnabled[wallet] = true;
        _isExcludedFromFees[wallet] = true;
        dividendTracker.excludeFromDividends(wallet);
        emit SetPreSaleWallet(wallet);
    }

    function enableStaking(bool enable) public onlyOwner {
        require(stakingEnabled != enable);
        stakingEnabled = enable;

        emit EnableStaking(enable);
    }

    function stake(uint256 duration) public {
        require(stakingEnabled, "Staking is not enabled");
        require(stakingAmounts[duration] != 0, "Invalid staking duration");
        require(
            stakingUntilDate[_msgSender()] < block.timestamp.add(duration),
            "already staked for a longer duration"
        );

        stakingBonus[_msgSender()] = stakingAmounts[duration];
        stakingUntilDate[_msgSender()] = block.timestamp.add(duration);

        dividendTracker.setBalance(
            _msgSender(),
            getStakingBalance(_msgSender())
        );

        emit EnableAccountStaking(_msgSender(), duration);
    }

    function updateMaxAmount(uint256 newNum) public onlyOwner {
        require(maxSellTransactionAmount != newNum);
        // 0 means disabled
        require(
            maxSellTransactionAmount == 0 ||
                maxSellTransactionAmount >= 500000000000 * (10**9),
            "max sell amount must either be disabled or greater than 500 billion"
        );
        maxSellTransactionAmount = newNum * (10**9);
    }

    function excludeFromFees(address account, bool excluded) private onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function setSwapTriggerAmount(uint256 amount) public onlyOwner {
        swapTokensAtAmount = amount;
    }

    function enableSwapAndLiquify(bool enabled) public onlyOwner {
        require(swapAndLiquifyEnabled != enabled);
        swapAndLiquifyEnabled = enabled;

        emit EnableSwapAndLiquify(enabled);
    }

    function setAutomatedMarketMakerPair(address pair, bool value)
        public
        onlyOwner
    {
        require(pair != uniswapV2Pair);

        _setAutomatedMarketMakerPair(pair, value);
    }

    function setAllowCustomTokens(bool allow) public onlyOwner {
        dividendTracker.setAllowCustomTokens(allow);
    }

    function setAllowAutoReinvest(bool allow) public onlyOwner {
        dividendTracker.setAllowAutoReinvest(allow);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;

        if (value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000);
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function transferAdmin(address newOwner) public onlyOwner {
        dividendTracker.excludeFromDividends(newOwner);
        _isExcludedFromFees[newOwner] = true;
        transferOwnership(newOwner);
    }

    function updateFees(
        uint256 devBuy,
        uint256 devSell,
        uint256 marketingBuy,
        uint256 marketingSell,
        uint256 liquidityBuy,
        uint256 liquiditySell,
        uint256 BNBRewardsBuy,
        uint256 BNBRewardsSell
    ) public onlyOwner {
        require(
            buyDevFees <= 5 && sellDevFees <= 5,
            "Development fees can't exceed 5%"
        );
        require(
            buyMarketingFees <= 10 && sellMarketingFees <= 10,
            "Marketing fees can't exceed 10%"
        );
        require(
            buyLiquidityFee <= 5 && sellLiquidityFee <= 5,
            "Liquidity fees can't exceed 15%"
        );
        require(
            (BNBRewardsBuy >= 5 && BNBRewardsBuy <= 25) &&
                (BNBRewardsSell >= 5 && BNBRewardsSell <= 25),
            "BNB reward fees must be between 5 and 25"
        );

        buyDevFees = devBuy;
        buyMarketingFees = marketingBuy;
        buyLiquidityFee = liquidityBuy;
        buyBNBRewardsFee = BNBRewardsBuy;
        sellDevFees = devSell;
        sellMarketingFees = marketingSell;
        sellLiquidityFee = liquiditySell;
        sellBNBRewardsFee = BNBRewardsSell;

        totalSellFees = sellBNBRewardsFee
            .add(sellLiquidityFee)
            .add(sellDevFees)
            .add(sellMarketingFees);
        totalBuyFees = buyBNBRewardsFee
            .add(buyLiquidityFee)
            .add(buyDevFees)
            .add(buyMarketingFees);

        emit UpdateFees(
            sellDevFees,
            sellMarketingFees,
            sellLiquidityFee,
            sellBNBRewardsFee,
            buyDevFees,
            buyMarketingFees,
            buyLiquidityFee,
            buyBNBRewardsFee
        );
    }

    function getStakingInfo(address account)
        external
        view
        returns (uint256, uint256)
    {
        return (stakingUntilDate[account], stakingBonus[account]);
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function withdrawableDividendOf(address account)
        public
        view
        returns (uint256)
    {
        return dividendTracker.withdrawableDividendOf(account);
    }

    function dividendTokenBalanceOf(address account)
        public
        view
        returns (uint256)
    {
        return dividendTracker.balanceOf(account);
    }

    function getAccountDividendsInfo(address account)
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccount(account);
    }

    function getAccountDividendsInfoAtIndex(uint256 index)
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccountAtIndex(index);
    }

    function processDividendTracker(uint256 gas) external {
        (
            uint256 iterations,
            uint256 claims,
            uint256 lastProcessedIndex
        ) = dividendTracker.process(gas);
        emit ProcessedDividendTracker(
            iterations,
            claims,
            lastProcessedIndex,
            false,
            gas,
            tx.origin
        );
    }

    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns (uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function setAutoClaim(bool value) external {
        dividendTracker.setAutoClaim(msg.sender, value);
    }

    function setReinvest(bool value) external {
        dividendTracker.setReinvest(msg.sender, value);
    }

    function setDividendsPaused(bool value) external onlyOwner {
        dividendTracker.setDividendsPaused(value);
    }

    function isExcludedFromAutoClaim(address account)
        external
        view
        returns (bool)
    {
        return dividendTracker.isExcludedFromAutoClaim(account);
    }

    function isReinvest(address account) external view returns (bool) {
        return dividendTracker.isReinvest(account);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        uint256 BNBRewardsFee;
        uint256 devFees;
        uint256 marketingFees;
        uint256 liquidityFee;
        require(
            tradingEnabled || canTransferBeforeTradingIsEnabled[from],
            "Trading has not yet been enabled"
        );

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        } else if (
            !swapping && !_isExcludedFromFees[from] && !_isExcludedFromFees[to]
        ) {
            bool isSelling = automatedMarketMakerPairs[to];

            if (!automatedMarketMakerPairs[from] && stakingEnabled) {
                require(
                    stakingUntilDate[from] <= block.timestamp,
                    "Tokens are staked and locked!"
                );
                if (stakingUntilDate[from] != 0) {
                    stakingUntilDate[from] = 0;
                    stakingBonus[from] = 0;
                }
            }

            if (isSelling) {
                BNBRewardsFee = sellBNBRewardsFee;
                devFees = sellDevFees;
                marketingFees = sellMarketingFees;
                liquidityFee = sellLiquidityFee;
            } else {
                BNBRewardsFee = buyBNBRewardsFee;
                devFees = buyDevFees;
                marketingFees = buyMarketingFees;
                liquidityFee = buyLiquidityFee;
            }

            uint256 totalFees = BNBRewardsFee
                .add(liquidityFee)
                .add(devFees)
                .add(marketingFees);

            if (
                maxSellTransactionAmount != 0 &&
                isSelling && // sells only by detecting transfer to automated market maker pair
                from != address(uniswapV2Router) //router -> pair is removing liquidity which shouldn't have max
            ) {
                require(
                    amount <= maxSellTransactionAmount,
                    "maxSellTransactionAmount."
                );
            }

            uint256 contractTokenBalance = balanceOf(address(this));

            bool canSwap = contractTokenBalance >= swapTokensAtAmount;

            if (canSwap && !automatedMarketMakerPairs[from]) {
                swapping = true;

                if (swapAndLiquifyEnabled) {
                    uint256 totalBuySell = buyAmount.add(sellAmount);
                    uint256 swapAmountBought = contractTokenBalance
                        .mul(buyAmount)
                        .div(totalBuySell);
                    uint256 swapAmountSold = contractTokenBalance
                        .mul(sellAmount)
                        .div(totalBuySell);

                    uint256 swapBuyTokens = swapAmountBought
                        .mul(liquidityFee)
                        .div(totalBuyFees);

                    uint256 swapSellTokens = swapAmountSold
                        .mul(liquidityFee)
                        .div(totalSellFees);

                    uint256 swapTokens = swapSellTokens.add(swapBuyTokens);

                    swapAndLiquify(swapTokens);
                }

                uint256 remainingBalance = balanceOf(address(this));

                swapAndSendDividends(remainingBalance);

                buyAmount = 0;
                sellAmount = 0;

                swapping = false;
            }

            uint256 fees = amount.mul(totalFees).div(100);

            amount = amount.sub(fees);

            if (isSelling) {
                sellAmount = sellAmount.add(fees);
            } else {
                buyAmount = buyAmount.add(fees);
            }

            super._transfer(from, address(this), fees);

            uint256 gas = gasForProcessing;

            try dividendTracker.process(gas) returns (
                uint256 iterations,
                uint256 claims,
                uint256 lastProcessedIndex
            ) {
                emit ProcessedDividendTracker(
                    iterations,
                    claims,
                    lastProcessedIndex,
                    true,
                    gas,
                    tx.origin
                );
            } catch {}
        }

        super._transfer(from, to, amount);

        dividendTracker.setBalance(from, getStakingBalance(from));
        dividendTracker.setBalance(to, getStakingBalance(to));
    }

    function getStakingBalance(address account) private view returns (uint256) {
        return
            stakingEnabled
                ? balanceOf(account).mul(stakingBonus[account].add(100)).div(
                    100
                )
                : balanceOf(account);
    }

    function swapAndLiquify(uint256 tokens) private {
        // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function updatePayoutToken(address token) public {
        dividendTracker.updatePayoutToken(msg.sender, token);
        emit UpdatePayoutToken(msg.sender, token);
    }

    function getPayoutToken(address account) public view returns (address) {
        return dividendTracker.getPayoutToken(account);
    }

    function updateAllowTokens(address token, bool allow) public onlyOwner {
        require(token != uniswapV2Router.WETH());
        dividendTracker.updateAllowTokens(token, allow);
        emit UpdateAllowTokens(token, allow);
    }

    function getAllowTokens(address token) public view returns (bool) {
        return dividendTracker.getAllowTokens(token);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityWallet,
            block.timestamp
        );
    }

    function forceSwapAndSendDividends(uint256 tokens) public onlyOwner {
        uint256 totalAmount = buyAmount.add(sellAmount);
        uint256 fromBuy = tokens.mul(buyAmount).div(totalAmount);
        uint256 fromSell = tokens.mul(sellAmount).div(totalAmount);

        swapAndSendDividends(tokens);

        buyAmount = buyAmount.sub(fromBuy);
        sellAmount = sellAmount.sub(fromSell);
    }

    function swapAndSendDividends(uint256 tokens) private {
        swapTokensForEth(tokens);
        uint256 totalAmount = buyAmount.add(sellAmount);

        uint256 dividendsFromBuy = address(this)
            .balance
            .mul(buyAmount)
            .div(totalAmount)
            .mul(buyBNBRewardsFee)
            .div(buyBNBRewardsFee.add(buyDevFees + buyMarketingFees));

        uint256 dividendsFromSell = address(this)
            .balance
            .mul(sellAmount)
            .div(totalAmount)
            .mul(sellBNBRewardsFee)
            .div(sellBNBRewardsFee.add(sellDevFees + sellMarketingFees));

        uint256 dividends = dividendsFromBuy.add(dividendsFromSell);

        (bool success, ) = address(dividendTracker).call{value: dividends}("");

        uint256 feePortions = address(this).balance.div(
            sellMarketingFees.add(sellDevFees) +
                buyMarketingFees.add(buyDevFees)
        );

        uint256 marketingPayout = buyMarketingFees.add(sellMarketingFees) *
            feePortions;
        uint256 devPayout = buyDevFees.add(sellDevFees) * feePortions;

        /*
        uint256 theRest = address(this).balance;
        uint256 half = theRest.div(2);
        uint256 otherHalf = theRest - half;
*/

        (bool successOp1, ) = address(developmentWallet).call{value: devPayout}(
            ""
        );

        (bool successOp2, ) = address(marketingWallet).call{
            value: marketingPayout
        }("");

        emit SendDividends(
            dividends,
            devPayout + marketingPayout,
            success && successOp1 && successOp2
        );
    }

    /** 
    @dev sends tokens to multiple addresses, from sender wallet
    @param _contributors address[] array with addresses
    @param _balances uint256[] array with balances
     */
    function multiSend(
        address[] memory _contributors,
        uint256[] memory _balances
    ) public onlyOwner {
        require(
            _contributors.length == _balances.length,
            "Contributors and balances must be same size"
        );
        // Max 200 sends in bulk, uint8 in loop limited to 255
        require(
            _contributors.length <= 200,
            "Contributor list length must be <= 200"
        );
        uint256 sumOfBalances = 0;
        for (uint8 i = 0; i < _balances.length; i++) {
            sumOfBalances = sumOfBalances.add(_balances[i]);
        }
        require(
            balanceOf(msg.sender) >= sumOfBalances,
            "Account balance must be >= sum of balances. "
        );
        require(
            allowance(msg.sender, address(this)) >= sumOfBalances,
            "Contract allowance must be >= sum of balances. "
        );
        address contributor;
        uint256 origBalance;
        for (uint8 j; j < _contributors.length; j++) {
            contributor = _contributors[j];
            require(
                contributor != address(0) &&
                    contributor != 0x000000000000000000000000000000000000dEaD,
                "Cannot airdrop to a dead address"
            );
            origBalance = balanceOf(contributor);
            this.transferFrom(msg.sender, contributor, _balances[j]);
            require(
                balanceOf(contributor) == origBalance + _balances[j],
                "Contributor must recieve full balance of airdrop"
            );
            emit Airdrop(contributor, _balances[j]);
        }
    }
}

contract PocketDogeDividendTracker is DividendPayingToken, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping(address => bool) public excludedFromDividends;
    mapping(address => bool) public excludedFromAutoClaim;
    mapping(address => bool) public autoReinvest;
    mapping(address => address) public payoutToken;
    mapping(address => bool) public allowTokens;
    bool public allowCustomTokens;
    bool public allowAutoReinvest;
    bool public dividendsPaused = false;

    string private trackerName;
    string private trackerTicker;

    IUniswapV2Router02 public uniswapV2Router;

    PocketDoge public PocketDogeContract;

    mapping(address => uint256) public lastClaimTimes;

    uint256 private minimumTokenBalanceForAutoDividends;
    uint256 private minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event DividendReinvested(
        address indexed acount,
        uint256 value,
        bool indexed automatic
    );
    event Claim(
        address indexed account,
        uint256 amount,
        bool indexed automatic
    );
    event DividendsPaused(bool paused);
    event SetAllowCustomTokens(bool allow);
    event SetAllowAutoReinvest(bool allow);

    constructor(
        address payable mainContract,
        address router,
        string memory _name,
        string memory _ticker
    ) DividendPayingToken(_name, _ticker) {
        trackerName = _name;
        trackerTicker = _ticker;
        PocketDogeContract = PocketDoge(mainContract);
        minimumTokenBalanceForAutoDividends = (10**6) * (10**decimals()); // 10 million, 0,01% of supply
        minimumTokenBalanceForDividends = minimumTokenBalanceForAutoDividends;

        uniswapV2Router = IUniswapV2Router02(router);
        allowCustomTokens = true;
        allowAutoReinvest = true;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return trackerName;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return trackerTicker;
    }

    function _transfer(
        address,
        address,
        uint256
    ) internal pure override {
        require(false, "PocketDoge_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public pure override {
        require(
            false,
            "PocketDoge_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main PocketDoge contract."
        );
    }

    function isExcludedFromAutoClaim(address account)
        external
        view
        onlyOwner
        returns (bool)
    {
        return excludedFromAutoClaim[account];
    }

    function isReinvest(address account)
        external
        view
        onlyOwner
        returns (bool)
    {
        return autoReinvest[account];
    }

    function setAllowCustomTokens(bool allow) external onlyOwner {
        require(allowCustomTokens != allow);
        allowCustomTokens = allow;
        emit SetAllowCustomTokens(allow);
    }

    function setAllowAutoReinvest(bool allow) external onlyOwner {
        require(allowAutoReinvest != allow);
        allowAutoReinvest = allow;
        emit SetAllowAutoReinvest(allow);
    }

    function excludeFromDividends(address account) external onlyOwner {
        //require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        tokenHoldersMap.remove(account);

        emit ExcludeFromDividends(account);
    }

    function setAutoClaim(address account, bool value) external onlyOwner {
        excludedFromAutoClaim[account] = value;
    }

    function setReinvest(address account, bool value) external onlyOwner {
        autoReinvest[account] = value;
    }

    function setDividendsPaused(bool value) external onlyOwner {
        require(dividendsPaused != value);
        dividendsPaused = value;
        emit DividendsPaused(value);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount(address _account)
        public
        view
        returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime
        )
    {
        account = _account;

        index = tokenHoldersMap.getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if (index >= 0) {
            if (uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(
                    int256(lastProcessedIndex)
                );
            } else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length >
                    lastProcessedIndex
                    ? tokenHoldersMap.keys.length.sub(lastProcessedIndex)
                    : 0;

                iterationsUntilProcessed = index.add(
                    int256(processesUntilEndOfArray)
                );
            }
        }

        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);

        lastClaimTime = lastClaimTimes[account];
    }

    function getAccountAtIndex(uint256 index)
        public
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256
        )
    {
        if (index >= tokenHoldersMap.size()) {
            return (
                0x0000000000000000000000000000000000000000,
                -1,
                -1,
                0,
                0,
                0
            );
        }

        address account = tokenHoldersMap.getKeyAtIndex(index);

        return getAccount(account);
    }

    function setBalance(address account, uint256 newBalance)
        external
        onlyOwner
    {
        if (excludedFromDividends[account]) {
            return;
        }

        if (newBalance < minimumTokenBalanceForDividends) {
            tokenHoldersMap.remove(account);
            _setBalance(account, 0);

            return;
        }

        _setBalance(account, newBalance);

        if (newBalance >= minimumTokenBalanceForAutoDividends) {
            tokenHoldersMap.set(account, newBalance);
        } else {
            tokenHoldersMap.remove(account);
        }
    }

    function process(uint256 gas)
        public
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

        if (numberOfTokenHolders == 0 || dividendsPaused) {
            return (0, 0, lastProcessedIndex);
        }

        uint256 _lastProcessedIndex = lastProcessedIndex;

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 claims = 0;

        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if (_lastProcessedIndex >= numberOfTokenHolders) {
                _lastProcessedIndex = 0;
            }

            address account = tokenHoldersMap.keys[_lastProcessedIndex];

            if (!excludedFromAutoClaim[account]) {
                if (processAccount(payable(account), true)) {
                    claims++;
                }
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;

        return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic)
        public
        onlyOwner
        returns (bool)
    {
        if (dividendsPaused) {
            return false;
        }

        bool reinvest = autoReinvest[account];

        if (automatic && reinvest && !allowAutoReinvest) {
            return false;
        }

        uint256 amount = reinvest
            ? _reinvestDividendOfUser(account)
            : _withdrawDividendOfUser(account);

        if (amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            if (reinvest) {
                emit DividendReinvested(account, amount, automatic);
            } else {
                emit Claim(account, amount, automatic);
            }
            return true;
        }

        return false;
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function updatePayoutToken(address account, address token)
        public
        onlyOwner
    {
        require(allowTokens[token], "Token not in allow list");
        payoutToken[account] = token;
    }

    function getPayoutToken(address account) public view returns (address) {
        return payoutToken[account];
    }

    function updateAllowTokens(address token, bool allow) public onlyOwner {
        require(
            token != uniswapV2Router.WETH(),
            "Cannot set WBNB as Reward token"
        );
        allowTokens[token] = allow;
    }

    function getAllowTokens(address token) public view returns (bool) {
        return allowTokens[token];
    }

    function _reinvestDividendOfUser(address account)
        private
        returns (uint256)
    {
        uint256 _withdrawableDividend = withdrawableDividendOf(account);
        if (_withdrawableDividend > 0) {
            bool success;

            withdrawnDividends[account] = withdrawnDividends[account].add(
                _withdrawableDividend
            );

            address[] memory path = new address[](2);
            path[0] = uniswapV2Router.WETH();
            path[1] = address(PocketDogeContract);

            uint256 prevBalance = PocketDogeContract.balanceOf(address(this));

            // make the swap
            try
                uniswapV2Router
                    .swapExactETHForTokensSupportingFeeOnTransferTokens{
                    value: _withdrawableDividend
                }(
                    0, // accept any amount of Tokens
                    path,
                    address(this),
                    block.timestamp
                )
            {
                uint256 received = PocketDogeContract
                    .balanceOf(address(this))
                    .sub(prevBalance);
                if (received > 0) {
                    success = true;
                    PocketDogeContract.transfer(account, received);
                } else {
                    success = false;
                }
            } catch {
                success = false;
            }

            if (!success) {
                withdrawnDividends[account] = withdrawnDividends[account].sub(
                    _withdrawableDividend
                );
                return 0;
            }

            return _withdrawableDividend;
        }

        return 0;
    }

    function _withdrawDividendOfUser(address payable user)
        internal
        override
        returns (uint256)
    {
        uint256 _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] = withdrawnDividends[user].add(
                _withdrawableDividend
            );

            address tokenAddress = payoutToken[user];
            bool success;

            // if no tokenAddress assume bnb payout
            if (
                !allowCustomTokens ||
                tokenAddress == address(0) ||
                !allowTokens[tokenAddress]
            ) {
                (success, ) = user.call{
                    value: _withdrawableDividend,
                    gas: 3000
                }("");
            } else {
                //investor wants to be payed out in a custom token
                address[] memory path = new address[](2);
                path[0] = uniswapV2Router.WETH();
                path[1] = tokenAddress;

                try
                    uniswapV2Router
                        .swapExactETHForTokensSupportingFeeOnTransferTokens{
                        value: _withdrawableDividend
                    }(
                        0, // accept any amount of Tokens
                        path,
                        user,
                        block.timestamp
                    )
                {
                    success = true;
                } catch {
                    success = false;
                }
            }

            if (!success) {
                withdrawnDividends[user] = withdrawnDividends[user].sub(
                    _withdrawableDividend
                );
                return 0;
            } else {
                emit DividendWithdrawn(user, _withdrawableDividend);
            }

            return _withdrawableDividend;
        }

        return 0;
    }
}

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) internal view returns (uint256) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key)
        internal
        view
        returns (int256)
    {
        if (!map.inserted[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint256 index)
        internal
        view
        returns (address)
    {
        return map.keys[index];
    }

    function size(Map storage map) internal view returns (uint256) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        address key,
        uint256 val
    ) internal {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) internal {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}