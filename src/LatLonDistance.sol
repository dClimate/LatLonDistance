pragma solidity ^0.8.13;

import {PRBMathSD59x18 as P} from "prb-math/PRBMathSD59x18.sol";
import {Trigonometry as T} from "solidity-trigonometry/Trigonometry.sol";
import {Arcsin as A} from "solidity-trigonometry/Arcsin.sol";

library LatLonDistance {
  using P for int256;

  // IUGG mean radius (R_1) = 6371008.7714 meters, with 18 decimal points to keep consistent with PRBMath
  // DOI: 10.1007/BF02521480
  int256 constant earthRadius = 6371008771400000000000000;
  
  // with 18 decimal points
  int256 constant maxLat = 90000000000000000000;
  int256 constant minLat = -maxLat;
  int256 constant maxLon = 180000000000000000000;
  int256 constant minLon = -maxLon;

  modifier validLat(int256 _lat) {
    require(_lat <= maxLat, "Latitude too big");
    require(_lat >= minLat, "Latitude too small");
    _;
  }

  modifier validLon(int256 _lon) {
    require(_lon <= maxLon, "Longitude too big");
    require(_lon >= minLon, "Longitude too small");
    _;
  }

  // mpd1 = mulPiDiv180
  function mpd1(int256 _x) internal pure returns (int256) {
    return _x.mul(P.pi()).div(P.fromInt(180));
  }

  // sin^2((lat2 - lat1)/2)
  function aux1(int256 lat1, int256 lat2) internal pure returns (int256) {
    int256 TWO = P.fromInt(2);

    int256 t3 = lat2 > lat1
      ? lat2 - lat1
      : lat1 - lat2;

    // we are squaring the sine anyway so throw away the negative
    int256 t4 = t3.div(TWO);
    uint256 t5 = uint256(t4.abs());
    int256 t1 = T.sin(t5);

    int256 sinSq1 = t1.mul(t1);

    return sinSq1;
  }

  // cos(lat1) * cos(lat2)
  function aux2(int256 lat1, int256 lat2) internal pure returns (int256) {
    // cos(-x) = cos(x), so don't worry about negatives
    uint256 l1 = uint256(lat1.abs());
    uint256 l2 = uint256(lat2.abs());

    int256 cosProd = T.cos(l1).mul(T.cos(l2));

    return cosProd;
  }

  // sin^2((lon2 - lon1)/2)
  function aux3(int256 lon1, int256 lon2) internal pure returns (int256) {
    int256 TWO = P.fromInt(2);
    
    int256 t1 = lon2 > lon1
      ? lon2 - lon1
      : lon1 - lon2;
    t1 = mpd1(t1);

    t1 = t1.div(TWO).abs();
    uint256 t3 = uint256(t1);

    int256 t2 = T.sin(t3);
    int256 sinSq2 = t2.mul(t2);

    return sinSq2;
  }

  function distance(int256 _lat1, int256 _lon1, int256 _lat2, int256 _lon2) internal pure 
  validLat(_lat1) validLat(_lat2) validLon(_lon1) validLon(_lon2)
  returns (int256) {
    _lat1 = mpd1(_lat1);
    _lat2 = mpd1(_lat2);

    // sin^2((lat2 - lat1)/2)
    int256 a1 = aux1(_lat1, _lat2);

    // cos(lat1) * cos(lat2)
    int256 a2 = aux2(_lat1, _lat2);

    // sin^2((lon2 - lon1)/2)
    int256 a3 = aux3(_lon1, _lon2);

    int256 a4 = a1 + a2.mul(a3);
    int256 a5 = a4.sqrt();

    int256 TWO = P.fromInt(2);
    int256 a6 = A.arcsin(a5);

    int256 result = a6.mul(earthRadius).mul(TWO);

    return result;
  }
}