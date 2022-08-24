pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {PRBMathSD59x18 as P} from "prb-math/PRBMathSD59x18.sol";
import {LatLonDistance as L} from "src/LatLonDistance.sol";

contract LatLonDistanceTest is Test {
  // relative tolerance, 5e14 = 0.05%
  uint256 constant TOL = 5e14;

  // test reference distances are calculated from
  // https://www.movable-type.co.uk/scripts/latlong.html

  // goes over true north
  function testDistanceTrueNorth() public {
    int256 lat1 = P.fromInt(60);
    int256 lon1 = P.fromInt(90);
    int256 lat2 = P.fromInt(60);
    int256 lon2 = P.fromInt(-90);

    int256 actual = L.distance(lat1, lon1, lat2, lon2);
    // 6672000 m
    int256 expected = P.fromInt(6672000);

    assertApproxEqRel(actual, expected, TOL);
  }

  // goes over true south
  function testDistanceTrueSouth() public {
    int256 lat1 = P.fromInt(-10);
    int256 lon1 = P.fromInt(90);
    int256 lat2 = P.fromInt(-10);
    int256 lon2 = P.fromInt(-90);

    int256 actual = L.distance(lat1, lon1, lat2, lon2);
    int256 expected = P.fromInt(17790000);

    assertApproxEqRel(actual, expected, TOL);
  }

  // goes over line where latitude flips sign
  function testDistanceLatBorder() public {
    int256 lat1 = P.fromInt(-5);
    int256 lon1 = 0;
    int256 lat2 = P.fromInt(5);
    int256 lon2 = 0;

    int256 actual = L.distance(lat1, lon1, lat2, lon2);
    // 1112 km
    int256 expected = P.fromInt(1112000);

    assertApproxEqRel(actual, expected, TOL);
  }


  // goes over line where longitude flips sign
  function testDistanceLonBorder() public {
    int256 lat1 = 0;
    int256 lon1 = P.fromInt(-179);
    int256 lat2 = 0;
    int256 lon2 = P.fromInt(179);

    int256 actual = L.distance(lat1, lon1, lat2, lon2);
    // 222.4 km
    int256 expected = P.fromInt(222400);

    assertApproxEqRel(actual, expected, TOL);
  }

  function testDistance0() public {
    int256 lat1 = P.fromInt(3);
    int256 lon1 = P.fromInt(3);
    int256 lat2 = P.fromInt(3);
    int256 lon2 = P.fromInt(3);

    int256 actual = L.distance(lat1, lon1, lat2, lon2);
    // 0 cause it should be the same point
    int256 expected = 0;

    assertApproxEqRel(actual, expected, TOL);
  }


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


  function testDistance2() public {
    int256 lat1 = P.fromInt(0);
    int256 lon1 = P.fromInt(-5);
    int256 lat2 = P.fromInt(0);
    int256 lon2 = P.fromInt(0);

    int256 actual = L.distance(lat1, lon1, lat2, lon2);
    int256 expected = P.fromInt(556000);

    assertApproxEqRel(actual, expected, TOL);
  }

  // smallest the function still works for with the TOL listed above
  function testDistance3() public {
    int256 lat1 = 0;
    int256 lon1 = 0;
    int256 lat2 = 0;
    // 0.01
    int256 lon2 = 1e16;

    int256 actual = L.distance(lat1, lon1, lat2, lon2);
    // 1.112 km = 1112 m
    int256 expected = 1112e18;

    assertApproxEqRel(actual, expected, TOL);
  }
}
