# FundMe-Solidity

in this project we've learn many advance solidity topics.

1. How to import third part contract for example chainlink to get price feed data.

```
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        );

(, int256 answer, , , ) = priceFeed.latestRoundData();

// ETH/USD rate in 18 digit

return uint256(answer * 10000000000);
```
2. constructor

When we deploy a contract at that time in the if we want to perform any operatio nwe can use constructor.

3. modifier

modifier is the way to defind require statement once and can utilize in many places.

4. error handling using requrie statement

5. library

> library is like a contract but we can not declare any variable or can't store any value in it.


### go through the code to understand it better. have put a comment whenever it required 


