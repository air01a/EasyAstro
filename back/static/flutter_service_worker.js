'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/appimages/B33.jpg": "d44d75e639ace9f2e01a01263d37e2b5",
"assets/appimages/background_dark.jpg": "6d672e1a1783c171af477ab06eb8de35",
"assets/appimages/Jupiter.jpg": "6b079bb3b0d03d471e7e5ce5b8125cfd",
"assets/appimages/M1.jpg": "25e7c40ff73ae85c241d0ca6cd14d0b3",
"assets/appimages/M10.jpg": "b1f8b8e614d23e3d0204814888075781",
"assets/appimages/M100.jpg": "54695a02ede9e861843eef12735bd1ed",
"assets/appimages/M101.jpg": "bc2269f846dd998da53eed532bd19dff",
"assets/appimages/M102.jpg": "586578ae337dd29d39503e6e0d7c18fa",
"assets/appimages/M103.jpg": "aa9f52d2b6751ac62ecf98053bf96a6c",
"assets/appimages/M104.jpg": "e9d7bcc395525a6d7a2b6fca9ab3f81e",
"assets/appimages/M105.jpg": "6b3fc2cc0f7b791b48a98b7ce8d9f688",
"assets/appimages/M106.jpg": "567bf167a086736306addad070ce20af",
"assets/appimages/M107.jpg": "0fcf4af6bdde305cb1be3788b558c759",
"assets/appimages/M108.jpg": "2a13264d55819d4f7bc10cdf16d66691",
"assets/appimages/M109.jpg": "d18f9ec251982745c563b8a32609fc49",
"assets/appimages/M11.jpg": "9515abed4a96ac6bd6f0e773475b4bef",
"assets/appimages/M110.jpg": "2577d8255d7d67debc9c06c16e0c08a1",
"assets/appimages/M12.jpg": "99bac779310fb7f6e779e8a35bb3883b",
"assets/appimages/M13.jpg": "5f1b58693c90c4bbcbf53fdeaf4182b6",
"assets/appimages/M14.jpg": "c354801e63b28d9befb52473a284cedd",
"assets/appimages/M15.jpg": "2d549989c9bed4dea83003c48bf6eb6e",
"assets/appimages/M16.jpg": "07c8559c4783967bc4e10ec8f062daac",
"assets/appimages/M17.jpg": "f9a210a5386350b8ee190b4e48ccfa9a",
"assets/appimages/M18.jpg": "8a8d30708b2dc53505c07629d44a18a5",
"assets/appimages/M19.jpg": "52475aaf61811d9125612608daf7d52b",
"assets/appimages/M2.jpg": "20ababb8f53acf11cc1a0b2094ea1ee2",
"assets/appimages/M20.jpg": "496e6881585fc54d84bfebc60423be81",
"assets/appimages/M21.jpg": "d6ccecd6747a2f800fe8058bd5103797",
"assets/appimages/M22.jpg": "98adf0a45b162a8afd34c16fa045a24e",
"assets/appimages/M23.jpg": "a62fd6e33f3969b7f218cd0177c760c4",
"assets/appimages/M24.jpg": "c6cb06b0ff0fda4a98049b76d19c6087",
"assets/appimages/M25.jpg": "b74683e9c9d299e995dd528a5135032b",
"assets/appimages/M26.jpg": "6c5e22d28d3c5b743124e75a9d233ed6",
"assets/appimages/M27.jpg": "45e5b7c8ee5004c1a41938a4d66b7b32",
"assets/appimages/M28.jpg": "446a6718f7191574df3b22e5bd505f47",
"assets/appimages/M29.jpg": "33ab26c968034979eab51a701434bbb1",
"assets/appimages/M3.jpg": "2cf5eeff3332e378904da5dcbf876ed1",
"assets/appimages/M30.jpg": "897c6f719077ab0375dab1f6db2419de",
"assets/appimages/M31.jpg": "e21d635aca2eeae08314dc9e445948c6",
"assets/appimages/M32.jpg": "ff06b4934d2a6a5c2744416ff6fb204f",
"assets/appimages/M33.jpg": "28389170611a6f50640314280c12d8cd",
"assets/appimages/M34.jpg": "2b0b8dafaef44c955df0d954da0805c6",
"assets/appimages/M35.jpg": "712f2c5696d2ae68c2785f8215ece6a7",
"assets/appimages/M36.jpg": "2ae1e03a713be2ef14ea887e14ba78b7",
"assets/appimages/M37.jpg": "661e12212071045a19805bbe195edf2b",
"assets/appimages/M38.jpg": "a23969e09571971032bf899197609a33",
"assets/appimages/M39.jpg": "e076c5041a0d115fc79f3a133a119c77",
"assets/appimages/M4.jpg": "a3c80bb4c3ae817897d2b144666b0b88",
"assets/appimages/M40.jpg": "5bf4eb2183679e646219ca7e63696ad8",
"assets/appimages/M41.jpg": "6cf21878cd91c8a1666207818e592734",
"assets/appimages/M42.jpg": "4d8d62883fe0254bac18a69251383980",
"assets/appimages/M43.jpg": "40951f7fc19b41c36e7434288c864747",
"assets/appimages/M44.jpg": "5ce0b788829b2705ebba1ee50af29e52",
"assets/appimages/M45.jpg": "7817b1facaee0065b220b5cdd4fe6821",
"assets/appimages/M46.jpg": "d0e572aa3f2877ee41d1f56024a6502b",
"assets/appimages/M47.jpg": "9d668559990e38a185cf0855bdb70828",
"assets/appimages/M48.jpg": "af679f569c4dd95d57657134aac58b8f",
"assets/appimages/M49.jpg": "a10dc6854bf9410895bc9a06c44a293f",
"assets/appimages/M5.jpg": "22292ff13666875f315bfe9ce1da8bfe",
"assets/appimages/M50.jpg": "361a99ffbd8d2076f2cdb9c3d1a3d4d6",
"assets/appimages/M51.jpg": "b38e5e7ece5632ccb2e632a593863819",
"assets/appimages/M52.jpg": "3ef29fb5029358f5d50033aa627b7223",
"assets/appimages/M53.jpg": "0bc413a50fcc48e0a5b2575fd8f91115",
"assets/appimages/M54.jpg": "a0861b4753e2ce05739cc2de78e4d34c",
"assets/appimages/M55.jpg": "bc15d08a1aa4f03d7dc04270007d3220",
"assets/appimages/M56.jpg": "fafcaa8114e52415b05ace4d61013aa2",
"assets/appimages/M57.jpg": "accb82b3f3074d77efa69349e2a33326",
"assets/appimages/M58.jpg": "7a442c74786618891eb91a19f979110c",
"assets/appimages/M59.jpg": "18d378119dc07c70145cf71298005b0a",
"assets/appimages/M6.jpg": "95ff42a8326db205f1c47e099c9e8459",
"assets/appimages/M60.jpg": "ae12adb2411e3bce936721b2f1ca92a3",
"assets/appimages/M61.jpg": "e5ae74aec993ea382d2319fc6c6b8b55",
"assets/appimages/M62.jpg": "29945f712101a13bd95b71eedb74bf35",
"assets/appimages/M63.jpg": "41856e604bbb283e8642eb885ae58e93",
"assets/appimages/M64.jpg": "2ef15148d6a80ba1b05f8258234b7591",
"assets/appimages/M65.jpg": "bdfd7d48ffa62b529abf5c6dd2e0ae31",
"assets/appimages/M66.jpg": "c34cdaad0fbb63255e65ea735b8bf384",
"assets/appimages/M67.jpg": "811d312e3d744d95d00ca2cac133721b",
"assets/appimages/M68.jpg": "00f32ff66c1e23ad4f1b1b9f68e1be25",
"assets/appimages/M69.jpg": "e002cd50c58dc198afe4bdca4ca36abe",
"assets/appimages/M7.jpg": "f300bf04d0e0b593b57d0f1eb8f23874",
"assets/appimages/M70.jpg": "cf17b998870958d0a7ee07f80f9cbed3",
"assets/appimages/M71.jpg": "bc8d525d68dad814db76ba1628568205",
"assets/appimages/M72.jpg": "9576cbe365153ab09a48c5da3fc0bb5f",
"assets/appimages/M73.jpg": "26f7cb7246cdcb77e628f9e630926444",
"assets/appimages/M74.jpg": "fa96455b7c90ccfdf776d9dbe7760451",
"assets/appimages/M75.jpg": "80d5ae750f05c3ad75a9fa79e1492c65",
"assets/appimages/M76.jpg": "e532e862250a84f284f289bb4e63993f",
"assets/appimages/M77.jpg": "04e983793c350124ad19d002dcb27710",
"assets/appimages/M78.jpg": "5da80eb3a181e28e6e71855fe297e378",
"assets/appimages/M79.jpg": "4bb9f24e81cdc97b9088fde5f52a7fa9",
"assets/appimages/M8.jpg": "a486f9d565dbb0eb6cd16d9e12bd978f",
"assets/appimages/M80.jpg": "6c65921272ba346e84c906a008a0c014",
"assets/appimages/M81.jpg": "efe380568636c63c1074db5eee080a7b",
"assets/appimages/M82.jpg": "12282897dfe9f4680e261a77ce206581",
"assets/appimages/M83.jpg": "7f875d5e0aa98b9d48185fd98623c83f",
"assets/appimages/M84.jpg": "f1c9577013d71cfe0cdc7cf42645b680",
"assets/appimages/M85.jpg": "6600ded9b27455624721a4450116a530",
"assets/appimages/M86.jpg": "c7174109eb0f02dc4ff47502f3f4cd27",
"assets/appimages/M87.jpg": "8051d45a391b6fff9fc882c5b07c4ed7",
"assets/appimages/M88.jpg": "a12d04781c1e34977a8cbbb0c0be6b7a",
"assets/appimages/M89.jpg": "9844e848dd499c50491bf42d9a5bc0ae",
"assets/appimages/M9.jpg": "9bb63b52be2312ff26e37c02f929b728",
"assets/appimages/M90.jpg": "06d9bf7dbf0d6338f3beb3416475e4e4",
"assets/appimages/M91.jpg": "3a325deb08a21dd1041430f20fd05461",
"assets/appimages/M92.jpg": "8c751dcd1798b01fa3a6e4176bb6bbdd",
"assets/appimages/M93.jpg": "038abf50cb650d3cb0bf73b59c68ed61",
"assets/appimages/M94.jpg": "63b5e056678e255138720d06dc3514b8",
"assets/appimages/M95.jpg": "42e8429e5dfbbe86a6bda9e796419860",
"assets/appimages/M96.jpg": "fc61b1d21d846444209761d1a9937b3d",
"assets/appimages/M97.jpg": "dae12d8299f5aecc829032813d8522a0",
"assets/appimages/M98.jpg": "a4399060b25380c2cb9ec28aecc853c8",
"assets/appimages/M99.jpg": "2e72ae93067139c301ed009e7262084f",
"assets/appimages/Mars.jpg": "6191e9fb0756f3162855ea458d7c2d9a",
"assets/appimages/Moon.jpg": "c66662d6de8e7c144d17695a217c5b0f",
"assets/appimages/moon0.png": "3c9bbb1146b579d48a81868ecbfdcc04",
"assets/appimages/moon1.png": "a0cca08e6364575edf99664def54e961",
"assets/appimages/moon10.png": "19f0d4201a352447019c198a7f55d241",
"assets/appimages/moon11.png": "eefb5e546f7dbd8b5f8a5df387569652",
"assets/appimages/moon12.png": "0e1cdff1259c2efac2749a689a6732cb",
"assets/appimages/moon13.png": "a5da03b0e9a8124819a97217675d3e8d",
"assets/appimages/moon14.png": "b0b133c0de3a92d699d8754ab0a26789",
"assets/appimages/moon15.png": "b1f44b1832b3e5c03ea33547fe98bc29",
"assets/appimages/moon16.png": "1295aab3da23d00a6a660d3f6888a27d",
"assets/appimages/moon17.png": "9ec41d25e50738ee659a701a66e112a2",
"assets/appimages/moon18.png": "8640f9af02cba43516417f919e42a5e9",
"assets/appimages/moon19.png": "d51f3fbfebea40a17a2b4386a050d0f8",
"assets/appimages/moon2.png": "3cffdde2005b568739b3ea6f3d6f2cc2",
"assets/appimages/moon20.png": "ccf0152275ba5fe95a94611a09eee205",
"assets/appimages/moon21.png": "f34ec4776718c9672de5e3b0ce3a6c17",
"assets/appimages/moon22.png": "308f6c66afbbcc4a141bdef2cd684c06",
"assets/appimages/moon23.png": "cf65394f871a86c46399e19f0c849875",
"assets/appimages/moon3.PNG": "30fa915f27ef52a6c3d9b9f0064b4912",
"assets/appimages/moon4.PNG": "bb2054fde171b31093f3f2cc2ff683c5",
"assets/appimages/moon5.PNG": "8de525c5724afd55cb015da6eea49a24",
"assets/appimages/moon6.PNG": "309996f3451d85186192e431715f913d",
"assets/appimages/moon7.PNG": "5b9ee02d60879e88321ba4e0a87b0781",
"assets/appimages/moon8.png": "e7edf8fc980dfe8686fca3a5724a5526",
"assets/appimages/moon9.png": "3d5731701cc8c8eaa0546695c139eeda",
"assets/appimages/moon_phase.jpg": "c4760708c265438f1c9c25349cd43146",
"assets/appimages/Saturn.jpg": "59a2185b0b67115c76c6aa2e50701b41",
"assets/appimages/Sun.jpg": "6777691e357cd1bb7091d436717beb85",
"assets/appimages/Venus.jpg": "baa372593389b3d098b9019f9d142d9f",
"assets/AssetManifest.bin": "88941d96ebdc7f22151584febda3637c",
"assets/AssetManifest.json": "1c4a3d201834712b4e3baf73cb81ed66",
"assets/assets/appimages/B33.jpg": "d44d75e639ace9f2e01a01263d37e2b5",
"assets/assets/appimages/background_dark.jpg": "6d672e1a1783c171af477ab06eb8de35",
"assets/assets/appimages/Jupiter.jpg": "6b079bb3b0d03d471e7e5ce5b8125cfd",
"assets/assets/appimages/M1.jpg": "25e7c40ff73ae85c241d0ca6cd14d0b3",
"assets/assets/appimages/M10.jpg": "b1f8b8e614d23e3d0204814888075781",
"assets/assets/appimages/M100.jpg": "54695a02ede9e861843eef12735bd1ed",
"assets/assets/appimages/M101.jpg": "bc2269f846dd998da53eed532bd19dff",
"assets/assets/appimages/M102.jpg": "586578ae337dd29d39503e6e0d7c18fa",
"assets/assets/appimages/M103.jpg": "aa9f52d2b6751ac62ecf98053bf96a6c",
"assets/assets/appimages/M104.jpg": "e9d7bcc395525a6d7a2b6fca9ab3f81e",
"assets/assets/appimages/M105.jpg": "6b3fc2cc0f7b791b48a98b7ce8d9f688",
"assets/assets/appimages/M106.jpg": "567bf167a086736306addad070ce20af",
"assets/assets/appimages/M107.jpg": "0fcf4af6bdde305cb1be3788b558c759",
"assets/assets/appimages/M108.jpg": "2a13264d55819d4f7bc10cdf16d66691",
"assets/assets/appimages/M109.jpg": "d18f9ec251982745c563b8a32609fc49",
"assets/assets/appimages/M11.jpg": "9515abed4a96ac6bd6f0e773475b4bef",
"assets/assets/appimages/M110.jpg": "2577d8255d7d67debc9c06c16e0c08a1",
"assets/assets/appimages/M12.jpg": "99bac779310fb7f6e779e8a35bb3883b",
"assets/assets/appimages/M13.jpg": "5f1b58693c90c4bbcbf53fdeaf4182b6",
"assets/assets/appimages/M14.jpg": "c354801e63b28d9befb52473a284cedd",
"assets/assets/appimages/M15.jpg": "2d549989c9bed4dea83003c48bf6eb6e",
"assets/assets/appimages/M16.jpg": "07c8559c4783967bc4e10ec8f062daac",
"assets/assets/appimages/M17.jpg": "f9a210a5386350b8ee190b4e48ccfa9a",
"assets/assets/appimages/M18.jpg": "8a8d30708b2dc53505c07629d44a18a5",
"assets/assets/appimages/M19.jpg": "52475aaf61811d9125612608daf7d52b",
"assets/assets/appimages/M2.jpg": "20ababb8f53acf11cc1a0b2094ea1ee2",
"assets/assets/appimages/M20.jpg": "496e6881585fc54d84bfebc60423be81",
"assets/assets/appimages/M21.jpg": "d6ccecd6747a2f800fe8058bd5103797",
"assets/assets/appimages/M22.jpg": "98adf0a45b162a8afd34c16fa045a24e",
"assets/assets/appimages/M23.jpg": "a62fd6e33f3969b7f218cd0177c760c4",
"assets/assets/appimages/M24.jpg": "c6cb06b0ff0fda4a98049b76d19c6087",
"assets/assets/appimages/M25.jpg": "b74683e9c9d299e995dd528a5135032b",
"assets/assets/appimages/M26.jpg": "6c5e22d28d3c5b743124e75a9d233ed6",
"assets/assets/appimages/M27.jpg": "45e5b7c8ee5004c1a41938a4d66b7b32",
"assets/assets/appimages/M28.jpg": "446a6718f7191574df3b22e5bd505f47",
"assets/assets/appimages/M29.jpg": "33ab26c968034979eab51a701434bbb1",
"assets/assets/appimages/M3.jpg": "2cf5eeff3332e378904da5dcbf876ed1",
"assets/assets/appimages/M30.jpg": "897c6f719077ab0375dab1f6db2419de",
"assets/assets/appimages/M31.jpg": "e21d635aca2eeae08314dc9e445948c6",
"assets/assets/appimages/M32.jpg": "ff06b4934d2a6a5c2744416ff6fb204f",
"assets/assets/appimages/M33.jpg": "28389170611a6f50640314280c12d8cd",
"assets/assets/appimages/M34.jpg": "2b0b8dafaef44c955df0d954da0805c6",
"assets/assets/appimages/M35.jpg": "712f2c5696d2ae68c2785f8215ece6a7",
"assets/assets/appimages/M36.jpg": "2ae1e03a713be2ef14ea887e14ba78b7",
"assets/assets/appimages/M37.jpg": "661e12212071045a19805bbe195edf2b",
"assets/assets/appimages/M38.jpg": "a23969e09571971032bf899197609a33",
"assets/assets/appimages/M39.jpg": "e076c5041a0d115fc79f3a133a119c77",
"assets/assets/appimages/M4.jpg": "a3c80bb4c3ae817897d2b144666b0b88",
"assets/assets/appimages/M40.jpg": "5bf4eb2183679e646219ca7e63696ad8",
"assets/assets/appimages/M41.jpg": "6cf21878cd91c8a1666207818e592734",
"assets/assets/appimages/M42.jpg": "4d8d62883fe0254bac18a69251383980",
"assets/assets/appimages/M43.jpg": "40951f7fc19b41c36e7434288c864747",
"assets/assets/appimages/M44.jpg": "5ce0b788829b2705ebba1ee50af29e52",
"assets/assets/appimages/M45.jpg": "7817b1facaee0065b220b5cdd4fe6821",
"assets/assets/appimages/M46.jpg": "d0e572aa3f2877ee41d1f56024a6502b",
"assets/assets/appimages/M47.jpg": "9d668559990e38a185cf0855bdb70828",
"assets/assets/appimages/M48.jpg": "af679f569c4dd95d57657134aac58b8f",
"assets/assets/appimages/M49.jpg": "a10dc6854bf9410895bc9a06c44a293f",
"assets/assets/appimages/M5.jpg": "22292ff13666875f315bfe9ce1da8bfe",
"assets/assets/appimages/M50.jpg": "361a99ffbd8d2076f2cdb9c3d1a3d4d6",
"assets/assets/appimages/M51.jpg": "b38e5e7ece5632ccb2e632a593863819",
"assets/assets/appimages/M52.jpg": "3ef29fb5029358f5d50033aa627b7223",
"assets/assets/appimages/M53.jpg": "0bc413a50fcc48e0a5b2575fd8f91115",
"assets/assets/appimages/M54.jpg": "a0861b4753e2ce05739cc2de78e4d34c",
"assets/assets/appimages/M55.jpg": "bc15d08a1aa4f03d7dc04270007d3220",
"assets/assets/appimages/M56.jpg": "fafcaa8114e52415b05ace4d61013aa2",
"assets/assets/appimages/M57.jpg": "accb82b3f3074d77efa69349e2a33326",
"assets/assets/appimages/M58.jpg": "7a442c74786618891eb91a19f979110c",
"assets/assets/appimages/M59.jpg": "18d378119dc07c70145cf71298005b0a",
"assets/assets/appimages/M6.jpg": "95ff42a8326db205f1c47e099c9e8459",
"assets/assets/appimages/M60.jpg": "ae12adb2411e3bce936721b2f1ca92a3",
"assets/assets/appimages/M61.jpg": "e5ae74aec993ea382d2319fc6c6b8b55",
"assets/assets/appimages/M62.jpg": "29945f712101a13bd95b71eedb74bf35",
"assets/assets/appimages/M63.jpg": "41856e604bbb283e8642eb885ae58e93",
"assets/assets/appimages/M64.jpg": "2ef15148d6a80ba1b05f8258234b7591",
"assets/assets/appimages/M65.jpg": "bdfd7d48ffa62b529abf5c6dd2e0ae31",
"assets/assets/appimages/M66.jpg": "c34cdaad0fbb63255e65ea735b8bf384",
"assets/assets/appimages/M67.jpg": "811d312e3d744d95d00ca2cac133721b",
"assets/assets/appimages/M68.jpg": "00f32ff66c1e23ad4f1b1b9f68e1be25",
"assets/assets/appimages/M69.jpg": "e002cd50c58dc198afe4bdca4ca36abe",
"assets/assets/appimages/M7.jpg": "f300bf04d0e0b593b57d0f1eb8f23874",
"assets/assets/appimages/M70.jpg": "cf17b998870958d0a7ee07f80f9cbed3",
"assets/assets/appimages/M71.jpg": "bc8d525d68dad814db76ba1628568205",
"assets/assets/appimages/M72.jpg": "9576cbe365153ab09a48c5da3fc0bb5f",
"assets/assets/appimages/M73.jpg": "26f7cb7246cdcb77e628f9e630926444",
"assets/assets/appimages/M74.jpg": "fa96455b7c90ccfdf776d9dbe7760451",
"assets/assets/appimages/M75.jpg": "80d5ae750f05c3ad75a9fa79e1492c65",
"assets/assets/appimages/M76.jpg": "e532e862250a84f284f289bb4e63993f",
"assets/assets/appimages/M77.jpg": "04e983793c350124ad19d002dcb27710",
"assets/assets/appimages/M78.jpg": "5da80eb3a181e28e6e71855fe297e378",
"assets/assets/appimages/M79.jpg": "4bb9f24e81cdc97b9088fde5f52a7fa9",
"assets/assets/appimages/M8.jpg": "a486f9d565dbb0eb6cd16d9e12bd978f",
"assets/assets/appimages/M80.jpg": "6c65921272ba346e84c906a008a0c014",
"assets/assets/appimages/M81.jpg": "efe380568636c63c1074db5eee080a7b",
"assets/assets/appimages/M82.jpg": "12282897dfe9f4680e261a77ce206581",
"assets/assets/appimages/M83.jpg": "7f875d5e0aa98b9d48185fd98623c83f",
"assets/assets/appimages/M84.jpg": "f1c9577013d71cfe0cdc7cf42645b680",
"assets/assets/appimages/M85.jpg": "6600ded9b27455624721a4450116a530",
"assets/assets/appimages/M86.jpg": "c7174109eb0f02dc4ff47502f3f4cd27",
"assets/assets/appimages/M87.jpg": "8051d45a391b6fff9fc882c5b07c4ed7",
"assets/assets/appimages/M88.jpg": "a12d04781c1e34977a8cbbb0c0be6b7a",
"assets/assets/appimages/M89.jpg": "9844e848dd499c50491bf42d9a5bc0ae",
"assets/assets/appimages/M9.jpg": "9bb63b52be2312ff26e37c02f929b728",
"assets/assets/appimages/M90.jpg": "06d9bf7dbf0d6338f3beb3416475e4e4",
"assets/assets/appimages/M91.jpg": "3a325deb08a21dd1041430f20fd05461",
"assets/assets/appimages/M92.jpg": "8c751dcd1798b01fa3a6e4176bb6bbdd",
"assets/assets/appimages/M93.jpg": "038abf50cb650d3cb0bf73b59c68ed61",
"assets/assets/appimages/M94.jpg": "63b5e056678e255138720d06dc3514b8",
"assets/assets/appimages/M95.jpg": "42e8429e5dfbbe86a6bda9e796419860",
"assets/assets/appimages/M96.jpg": "fc61b1d21d846444209761d1a9937b3d",
"assets/assets/appimages/M97.jpg": "dae12d8299f5aecc829032813d8522a0",
"assets/assets/appimages/M98.jpg": "a4399060b25380c2cb9ec28aecc853c8",
"assets/assets/appimages/M99.jpg": "2e72ae93067139c301ed009e7262084f",
"assets/assets/appimages/Mars.jpg": "6191e9fb0756f3162855ea458d7c2d9a",
"assets/assets/appimages/Moon.jpg": "c66662d6de8e7c144d17695a217c5b0f",
"assets/assets/appimages/moon0.png": "3c9bbb1146b579d48a81868ecbfdcc04",
"assets/assets/appimages/moon1.png": "a0cca08e6364575edf99664def54e961",
"assets/assets/appimages/moon10.png": "19f0d4201a352447019c198a7f55d241",
"assets/assets/appimages/moon11.png": "eefb5e546f7dbd8b5f8a5df387569652",
"assets/assets/appimages/moon12.png": "0e1cdff1259c2efac2749a689a6732cb",
"assets/assets/appimages/moon13.png": "a5da03b0e9a8124819a97217675d3e8d",
"assets/assets/appimages/moon14.png": "b0b133c0de3a92d699d8754ab0a26789",
"assets/assets/appimages/moon15.png": "b1f44b1832b3e5c03ea33547fe98bc29",
"assets/assets/appimages/moon16.png": "1295aab3da23d00a6a660d3f6888a27d",
"assets/assets/appimages/moon17.png": "9ec41d25e50738ee659a701a66e112a2",
"assets/assets/appimages/moon18.png": "8640f9af02cba43516417f919e42a5e9",
"assets/assets/appimages/moon19.png": "d51f3fbfebea40a17a2b4386a050d0f8",
"assets/assets/appimages/moon2.png": "3cffdde2005b568739b3ea6f3d6f2cc2",
"assets/assets/appimages/moon20.png": "ccf0152275ba5fe95a94611a09eee205",
"assets/assets/appimages/moon21.png": "f34ec4776718c9672de5e3b0ce3a6c17",
"assets/assets/appimages/moon22.png": "308f6c66afbbcc4a141bdef2cd684c06",
"assets/assets/appimages/moon23.png": "cf65394f871a86c46399e19f0c849875",
"assets/assets/appimages/moon3.PNG": "30fa915f27ef52a6c3d9b9f0064b4912",
"assets/assets/appimages/moon4.PNG": "bb2054fde171b31093f3f2cc2ff683c5",
"assets/assets/appimages/moon5.PNG": "8de525c5724afd55cb015da6eea49a24",
"assets/assets/appimages/moon6.PNG": "309996f3451d85186192e431715f913d",
"assets/assets/appimages/moon7.PNG": "5b9ee02d60879e88321ba4e0a87b0781",
"assets/assets/appimages/moon8.png": "e7edf8fc980dfe8686fca3a5724a5526",
"assets/assets/appimages/moon9.png": "3d5731701cc8c8eaa0546695c139eeda",
"assets/assets/appimages/moon_phase.jpg": "c4760708c265438f1c9c25349cd43146",
"assets/assets/appimages/Saturn.jpg": "59a2185b0b67115c76c6aa2e50701b41",
"assets/assets/appimages/Sun.jpg": "6777691e357cd1bb7091d436717beb85",
"assets/assets/appimages/Venus.jpg": "baa372593389b3d098b9019f9d142d9f",
"assets/assets/data/deepsky.lst": "bf24d485270d4dc81c985275f601267c",
"assets/assets/data/description_en": "1b6ab5f2d6c2bd4e24364a1d5bebb7be",
"assets/assets/translations/en-US.json": "33e1ef6f6b18825a873f2bdcd258eead",
"assets/assets/translations/fr-FR.json": "08e78b8d0395c33de12175f466534ec1",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "48dcf71d0b86b1dc65e63e33f2bd5b55",
"assets/NOTICES": "f41bb8db8daaccf273fcb67aa269cfad",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "57d849d738900cfd590e9adc7e208250",
"assets/packages/easy_localization/i18n/ar-DZ.json": "acc0a8eebb2fcee312764600f7cc41ec",
"assets/packages/easy_localization/i18n/ar.json": "acc0a8eebb2fcee312764600f7cc41ec",
"assets/packages/easy_localization/i18n/en-US.json": "5f5fda8715e8bf5116f77f469c5cf493",
"assets/packages/easy_localization/i18n/en.json": "5f5fda8715e8bf5116f77f469c5cf493",
"assets/packages/flutter_osm_web/src/asset/map.html": "d5f8bc7f5ecf2ebe54ce358ec9df9163",
"assets/packages/flutter_osm_web/src/asset/map.js": "aff7c1ec4ea7d88ed10022417d6675c5",
"assets/packages/flutter_osm_web/src/asset/map_init.js": "2015aa560219ada6e8bbb721afc62159",
"assets/packages/flutter_osm_web/src/asset/map_leaflet.js": "a331079409eb3b5d7bf0d49e9b3368cc",
"assets/packages/routing_client_dart/src/assets/en.json": "006f10a887beeb7207fc58db61426a4e",
"assets/packages/sweph/assets/ephe/seasnam.txt": "6958e1fbef7951aa5ff6bd4c9f2308fa",
"assets/packages/sweph/assets/ephe/seas_18.se1": "728e0c0d609c52f8b23c8cfdd7ac544a",
"assets/packages/sweph/assets/ephe/sefstars.txt": "89ca32a5e8bf17a70f91fa60e4f4b13a",
"assets/packages/sweph/assets/ephe/seleapsec.txt": "393624c4c96fe87f9485616a45f7d3b9",
"assets/packages/sweph/assets/ephe/semo_18.se1": "7d67f3203b5277865235529ed26eaf19",
"assets/packages/sweph/assets/ephe/seorbel.txt": "3e826114c1e87cf00439b58cb92c3b00",
"assets/packages/sweph/assets/ephe/sepl_18.se1": "76235ef7e2365da3e1e4492d5c3f7801",
"assets/packages/sweph/assets/sweph.wasm": "86bb41f54251a2f842df92029ea5a9f9",
"assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"assets/web/assets/appimages/B33.jpg": "d44d75e639ace9f2e01a01263d37e2b5",
"assets/web/assets/appimages/background_dark.jpg": "6d672e1a1783c171af477ab06eb8de35",
"assets/web/assets/appimages/Jupiter.jpg": "6b079bb3b0d03d471e7e5ce5b8125cfd",
"assets/web/assets/appimages/M1.jpg": "25e7c40ff73ae85c241d0ca6cd14d0b3",
"assets/web/assets/appimages/M10.jpg": "b1f8b8e614d23e3d0204814888075781",
"assets/web/assets/appimages/M100.jpg": "54695a02ede9e861843eef12735bd1ed",
"assets/web/assets/appimages/M101.jpg": "bc2269f846dd998da53eed532bd19dff",
"assets/web/assets/appimages/M102.jpg": "586578ae337dd29d39503e6e0d7c18fa",
"assets/web/assets/appimages/M103.jpg": "aa9f52d2b6751ac62ecf98053bf96a6c",
"assets/web/assets/appimages/M104.jpg": "e9d7bcc395525a6d7a2b6fca9ab3f81e",
"assets/web/assets/appimages/M105.jpg": "6b3fc2cc0f7b791b48a98b7ce8d9f688",
"assets/web/assets/appimages/M106.jpg": "567bf167a086736306addad070ce20af",
"assets/web/assets/appimages/M107.jpg": "0fcf4af6bdde305cb1be3788b558c759",
"assets/web/assets/appimages/M108.jpg": "2a13264d55819d4f7bc10cdf16d66691",
"assets/web/assets/appimages/M109.jpg": "d18f9ec251982745c563b8a32609fc49",
"assets/web/assets/appimages/M11.jpg": "9515abed4a96ac6bd6f0e773475b4bef",
"assets/web/assets/appimages/M110.jpg": "2577d8255d7d67debc9c06c16e0c08a1",
"assets/web/assets/appimages/M12.jpg": "99bac779310fb7f6e779e8a35bb3883b",
"assets/web/assets/appimages/M13.jpg": "5f1b58693c90c4bbcbf53fdeaf4182b6",
"assets/web/assets/appimages/M14.jpg": "c354801e63b28d9befb52473a284cedd",
"assets/web/assets/appimages/M15.jpg": "2d549989c9bed4dea83003c48bf6eb6e",
"assets/web/assets/appimages/M16.jpg": "07c8559c4783967bc4e10ec8f062daac",
"assets/web/assets/appimages/M17.jpg": "f9a210a5386350b8ee190b4e48ccfa9a",
"assets/web/assets/appimages/M18.jpg": "8a8d30708b2dc53505c07629d44a18a5",
"assets/web/assets/appimages/M19.jpg": "52475aaf61811d9125612608daf7d52b",
"assets/web/assets/appimages/M2.jpg": "20ababb8f53acf11cc1a0b2094ea1ee2",
"assets/web/assets/appimages/M20.jpg": "496e6881585fc54d84bfebc60423be81",
"assets/web/assets/appimages/M21.jpg": "d6ccecd6747a2f800fe8058bd5103797",
"assets/web/assets/appimages/M22.jpg": "98adf0a45b162a8afd34c16fa045a24e",
"assets/web/assets/appimages/M23.jpg": "a62fd6e33f3969b7f218cd0177c760c4",
"assets/web/assets/appimages/M24.jpg": "c6cb06b0ff0fda4a98049b76d19c6087",
"assets/web/assets/appimages/M25.jpg": "b74683e9c9d299e995dd528a5135032b",
"assets/web/assets/appimages/M26.jpg": "6c5e22d28d3c5b743124e75a9d233ed6",
"assets/web/assets/appimages/M27.jpg": "45e5b7c8ee5004c1a41938a4d66b7b32",
"assets/web/assets/appimages/M28.jpg": "446a6718f7191574df3b22e5bd505f47",
"assets/web/assets/appimages/M29.jpg": "33ab26c968034979eab51a701434bbb1",
"assets/web/assets/appimages/M3.jpg": "2cf5eeff3332e378904da5dcbf876ed1",
"assets/web/assets/appimages/M30.jpg": "897c6f719077ab0375dab1f6db2419de",
"assets/web/assets/appimages/M31.jpg": "e21d635aca2eeae08314dc9e445948c6",
"assets/web/assets/appimages/M32.jpg": "ff06b4934d2a6a5c2744416ff6fb204f",
"assets/web/assets/appimages/M33.jpg": "28389170611a6f50640314280c12d8cd",
"assets/web/assets/appimages/M34.jpg": "2b0b8dafaef44c955df0d954da0805c6",
"assets/web/assets/appimages/M35.jpg": "712f2c5696d2ae68c2785f8215ece6a7",
"assets/web/assets/appimages/M36.jpg": "2ae1e03a713be2ef14ea887e14ba78b7",
"assets/web/assets/appimages/M37.jpg": "661e12212071045a19805bbe195edf2b",
"assets/web/assets/appimages/M38.jpg": "a23969e09571971032bf899197609a33",
"assets/web/assets/appimages/M39.jpg": "e076c5041a0d115fc79f3a133a119c77",
"assets/web/assets/appimages/M4.jpg": "a3c80bb4c3ae817897d2b144666b0b88",
"assets/web/assets/appimages/M40.jpg": "5bf4eb2183679e646219ca7e63696ad8",
"assets/web/assets/appimages/M41.jpg": "6cf21878cd91c8a1666207818e592734",
"assets/web/assets/appimages/M42.jpg": "4d8d62883fe0254bac18a69251383980",
"assets/web/assets/appimages/M43.jpg": "40951f7fc19b41c36e7434288c864747",
"assets/web/assets/appimages/M44.jpg": "5ce0b788829b2705ebba1ee50af29e52",
"assets/web/assets/appimages/M45.jpg": "7817b1facaee0065b220b5cdd4fe6821",
"assets/web/assets/appimages/M46.jpg": "d0e572aa3f2877ee41d1f56024a6502b",
"assets/web/assets/appimages/M47.jpg": "9d668559990e38a185cf0855bdb70828",
"assets/web/assets/appimages/M48.jpg": "af679f569c4dd95d57657134aac58b8f",
"assets/web/assets/appimages/M49.jpg": "a10dc6854bf9410895bc9a06c44a293f",
"assets/web/assets/appimages/M5.jpg": "22292ff13666875f315bfe9ce1da8bfe",
"assets/web/assets/appimages/M50.jpg": "361a99ffbd8d2076f2cdb9c3d1a3d4d6",
"assets/web/assets/appimages/M51.jpg": "b38e5e7ece5632ccb2e632a593863819",
"assets/web/assets/appimages/M52.jpg": "3ef29fb5029358f5d50033aa627b7223",
"assets/web/assets/appimages/M53.jpg": "0bc413a50fcc48e0a5b2575fd8f91115",
"assets/web/assets/appimages/M54.jpg": "a0861b4753e2ce05739cc2de78e4d34c",
"assets/web/assets/appimages/M55.jpg": "bc15d08a1aa4f03d7dc04270007d3220",
"assets/web/assets/appimages/M56.jpg": "fafcaa8114e52415b05ace4d61013aa2",
"assets/web/assets/appimages/M57.jpg": "accb82b3f3074d77efa69349e2a33326",
"assets/web/assets/appimages/M58.jpg": "7a442c74786618891eb91a19f979110c",
"assets/web/assets/appimages/M59.jpg": "18d378119dc07c70145cf71298005b0a",
"assets/web/assets/appimages/M6.jpg": "95ff42a8326db205f1c47e099c9e8459",
"assets/web/assets/appimages/M60.jpg": "ae12adb2411e3bce936721b2f1ca92a3",
"assets/web/assets/appimages/M61.jpg": "e5ae74aec993ea382d2319fc6c6b8b55",
"assets/web/assets/appimages/M62.jpg": "29945f712101a13bd95b71eedb74bf35",
"assets/web/assets/appimages/M63.jpg": "41856e604bbb283e8642eb885ae58e93",
"assets/web/assets/appimages/M64.jpg": "2ef15148d6a80ba1b05f8258234b7591",
"assets/web/assets/appimages/M65.jpg": "bdfd7d48ffa62b529abf5c6dd2e0ae31",
"assets/web/assets/appimages/M66.jpg": "c34cdaad0fbb63255e65ea735b8bf384",
"assets/web/assets/appimages/M67.jpg": "811d312e3d744d95d00ca2cac133721b",
"assets/web/assets/appimages/M68.jpg": "00f32ff66c1e23ad4f1b1b9f68e1be25",
"assets/web/assets/appimages/M69.jpg": "e002cd50c58dc198afe4bdca4ca36abe",
"assets/web/assets/appimages/M7.jpg": "f300bf04d0e0b593b57d0f1eb8f23874",
"assets/web/assets/appimages/M70.jpg": "cf17b998870958d0a7ee07f80f9cbed3",
"assets/web/assets/appimages/M71.jpg": "bc8d525d68dad814db76ba1628568205",
"assets/web/assets/appimages/M72.jpg": "9576cbe365153ab09a48c5da3fc0bb5f",
"assets/web/assets/appimages/M73.jpg": "26f7cb7246cdcb77e628f9e630926444",
"assets/web/assets/appimages/M74.jpg": "fa96455b7c90ccfdf776d9dbe7760451",
"assets/web/assets/appimages/M75.jpg": "80d5ae750f05c3ad75a9fa79e1492c65",
"assets/web/assets/appimages/M76.jpg": "e532e862250a84f284f289bb4e63993f",
"assets/web/assets/appimages/M77.jpg": "04e983793c350124ad19d002dcb27710",
"assets/web/assets/appimages/M78.jpg": "5da80eb3a181e28e6e71855fe297e378",
"assets/web/assets/appimages/M79.jpg": "4bb9f24e81cdc97b9088fde5f52a7fa9",
"assets/web/assets/appimages/M8.jpg": "a486f9d565dbb0eb6cd16d9e12bd978f",
"assets/web/assets/appimages/M80.jpg": "6c65921272ba346e84c906a008a0c014",
"assets/web/assets/appimages/M81.jpg": "efe380568636c63c1074db5eee080a7b",
"assets/web/assets/appimages/M82.jpg": "12282897dfe9f4680e261a77ce206581",
"assets/web/assets/appimages/M83.jpg": "7f875d5e0aa98b9d48185fd98623c83f",
"assets/web/assets/appimages/M84.jpg": "f1c9577013d71cfe0cdc7cf42645b680",
"assets/web/assets/appimages/M85.jpg": "6600ded9b27455624721a4450116a530",
"assets/web/assets/appimages/M86.jpg": "c7174109eb0f02dc4ff47502f3f4cd27",
"assets/web/assets/appimages/M87.jpg": "8051d45a391b6fff9fc882c5b07c4ed7",
"assets/web/assets/appimages/M88.jpg": "a12d04781c1e34977a8cbbb0c0be6b7a",
"assets/web/assets/appimages/M89.jpg": "9844e848dd499c50491bf42d9a5bc0ae",
"assets/web/assets/appimages/M9.jpg": "9bb63b52be2312ff26e37c02f929b728",
"assets/web/assets/appimages/M90.jpg": "06d9bf7dbf0d6338f3beb3416475e4e4",
"assets/web/assets/appimages/M91.jpg": "3a325deb08a21dd1041430f20fd05461",
"assets/web/assets/appimages/M92.jpg": "8c751dcd1798b01fa3a6e4176bb6bbdd",
"assets/web/assets/appimages/M93.jpg": "038abf50cb650d3cb0bf73b59c68ed61",
"assets/web/assets/appimages/M94.jpg": "63b5e056678e255138720d06dc3514b8",
"assets/web/assets/appimages/M95.jpg": "42e8429e5dfbbe86a6bda9e796419860",
"assets/web/assets/appimages/M96.jpg": "fc61b1d21d846444209761d1a9937b3d",
"assets/web/assets/appimages/M97.jpg": "dae12d8299f5aecc829032813d8522a0",
"assets/web/assets/appimages/M98.jpg": "a4399060b25380c2cb9ec28aecc853c8",
"assets/web/assets/appimages/M99.jpg": "2e72ae93067139c301ed009e7262084f",
"assets/web/assets/appimages/Mars.jpg": "6191e9fb0756f3162855ea458d7c2d9a",
"assets/web/assets/appimages/Moon.jpg": "c66662d6de8e7c144d17695a217c5b0f",
"assets/web/assets/appimages/moon0.png": "3c9bbb1146b579d48a81868ecbfdcc04",
"assets/web/assets/appimages/moon1.png": "a0cca08e6364575edf99664def54e961",
"assets/web/assets/appimages/moon10.png": "19f0d4201a352447019c198a7f55d241",
"assets/web/assets/appimages/moon11.png": "eefb5e546f7dbd8b5f8a5df387569652",
"assets/web/assets/appimages/moon12.png": "0e1cdff1259c2efac2749a689a6732cb",
"assets/web/assets/appimages/moon13.png": "a5da03b0e9a8124819a97217675d3e8d",
"assets/web/assets/appimages/moon14.png": "b0b133c0de3a92d699d8754ab0a26789",
"assets/web/assets/appimages/moon15.png": "b1f44b1832b3e5c03ea33547fe98bc29",
"assets/web/assets/appimages/moon16.png": "1295aab3da23d00a6a660d3f6888a27d",
"assets/web/assets/appimages/moon17.png": "9ec41d25e50738ee659a701a66e112a2",
"assets/web/assets/appimages/moon18.png": "8640f9af02cba43516417f919e42a5e9",
"assets/web/assets/appimages/moon19.png": "d51f3fbfebea40a17a2b4386a050d0f8",
"assets/web/assets/appimages/moon2.png": "3cffdde2005b568739b3ea6f3d6f2cc2",
"assets/web/assets/appimages/moon20.png": "ccf0152275ba5fe95a94611a09eee205",
"assets/web/assets/appimages/moon21.png": "f34ec4776718c9672de5e3b0ce3a6c17",
"assets/web/assets/appimages/moon22.png": "308f6c66afbbcc4a141bdef2cd684c06",
"assets/web/assets/appimages/moon23.png": "cf65394f871a86c46399e19f0c849875",
"assets/web/assets/appimages/moon3.PNG": "30fa915f27ef52a6c3d9b9f0064b4912",
"assets/web/assets/appimages/moon4.PNG": "bb2054fde171b31093f3f2cc2ff683c5",
"assets/web/assets/appimages/moon5.PNG": "8de525c5724afd55cb015da6eea49a24",
"assets/web/assets/appimages/moon6.PNG": "309996f3451d85186192e431715f913d",
"assets/web/assets/appimages/moon7.PNG": "5b9ee02d60879e88321ba4e0a87b0781",
"assets/web/assets/appimages/moon8.png": "e7edf8fc980dfe8686fca3a5724a5526",
"assets/web/assets/appimages/moon9.png": "3d5731701cc8c8eaa0546695c139eeda",
"assets/web/assets/appimages/moon_phase.jpg": "c4760708c265438f1c9c25349cd43146",
"assets/web/assets/appimages/Saturn.jpg": "59a2185b0b67115c76c6aa2e50701b41",
"assets/web/assets/appimages/Sun.jpg": "6777691e357cd1bb7091d436717beb85",
"assets/web/assets/appimages/Venus.jpg": "baa372593389b3d098b9019f9d142d9f",
"canvaskit/canvaskit.js": "76f7d822f42397160c5dfc69cbc9b2de",
"canvaskit/canvaskit.wasm": "f48eaf57cada79163ec6dec7929486ea",
"canvaskit/chromium/canvaskit.js": "8c8392ce4a4364cbb240aa09b5652e05",
"canvaskit/chromium/canvaskit.wasm": "fc18c3010856029414b70cae1afc5cd9",
"canvaskit/skwasm.js": "1df4d741f441fa1a4d10530ced463ef8",
"canvaskit/skwasm.wasm": "6711032e17bf49924b2b001cef0d3ea3",
"canvaskit/skwasm.worker.js": "19659053a277272607529ef87acf9d8a",
"favicon.png": "375415b9d2de3fb832bf8ec62df84afa",
"flutter.js": "6b515e434cea20006b3ef1726d2c8894",
"icons/Icon-192.png": "6c47470b4a48246779da807ae06a5b7a",
"icons/Icon-512.png": "4d413acc7f1560a7f751f7d089e519c9",
"icons/Icon-maskable-192.png": "6c47470b4a48246779da807ae06a5b7a",
"icons/Icon-maskable-512.png": "4d413acc7f1560a7f751f7d089e519c9",
"index.html": "1460cbe964de202a1ec40f9f5479b542",
"/": "1460cbe964de202a1ec40f9f5479b542",
"main.dart.js": "376f65e87f66921b076bb693232baf51",
"manifest.json": "c63a656c23597a96b8440ff622c8eea3",
"translations/en-US.json": "e8808b5d8412c150f5a2c5177f45bc33",
"translations/fr-FR.json": "a6781e6949889af51549d9e55f2a920c",
"version.json": "99155b36fa333fb729cccdcbe38c9492"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
