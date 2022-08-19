pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {PRBMathSD59x18 as P} from "prb-math/PRBMathSD59x18.sol";
import {LatLonDistance as L} from "src/LatLonDistance.sol";

contract LatLonDistanceTest is Test {
 // relative tolerance, 1.5e14 = 0.015%
  uint256 constant TOL   = 1.5e14;

  function testDistance1() public {
    // lat = 40.897974 , lon = -97.450720
    int256 lat1 = 40897974000000000000;
    int256 lon1 = -97450720000000000000;
    // lat = 40.508131 , lon = -103.418150
    int256 lat2 = 40508131000000000000;
    int256 lon2 = -103418150000000000000;

    int256 actual = L.distance(lat1, lon1, lat2, lon2);
    // 504800 m
    int256 expected = P.fromInt(504800);

    assertApproxEqRel(actual, expected, TOL);
  }
}