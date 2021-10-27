import { Provider, OperationResult } from "../common/base"
import BigNumber from "@taquito/rpc/node_modules/bignumber.js"

export const exchangeV2_code : any =
  [  {  "prim": "storage",
        "args": [
          {  "prim": "pair",
             "args": [
               {  "prim": "address",
                  "annots": [
                    "%owner"
                  ]
               },
               {  "prim": "pair",
                  "args": [
                    {  "prim": "address",
                       "annots": [
                         "%defaultFeeReceiver"
                       ]
                    },
                    {  "prim": "pair",
                       "args": [
                         {  "prim": "nat",
                            "annots": [
                              "%protocolFee"
                            ]
                         },
                         {  "prim": "pair",
                            "args": [
                              {  "prim": "option",
                                 "args": [
                                   {  "prim": "address"  }
                                 ]
                                 ,
                                 "annots": [
                                   "%owner_candidate"
                                 ]
                              },
                              {  "prim": "pair",
                                 "args": [
                                   {  "prim": "map",
                                      "args": [
                                        {  "prim": "address"  },
                                        {  "prim": "address"  }
                                      ]
                                      ,
                                      "annots": [
                                        "%feeReceivers"
                                      ]
                                   },
                                   {  "prim": "pair",
                                      "args": [
                                        {  "prim": "option",
                                           "args": [
                                             {  "prim": "address"  }
                                           ]
                                           ,
                                           "annots": [
                                             "%validator"
                                           ]
                                        },
                                        {  "prim": "big_map",
                                           "args": [
                                             {  "prim": "string"  },
                                             {  "prim": "bytes"  }
                                           ]
                                           ,
                                           "annots": [
                                             "%metadata"
                                           ]
                                        }
                                      ]
                                   }
                                 ]
                              }
                            ]
                         }
                       ]
                    }
                  ]
               }
             ]
          }
        ]
  },
  {  "prim": "parameter",
     "args": [
       {  "prim": "or",
          "args": [
            {  "prim": "or",
               "args": [
                 {  "prim": "or",
                    "args": [
                      {  "prim": "or",
                         "args": [
                           {  "prim": "address",
                              "annots": [
                                "%setValidator"
                              ]
                           },
                           {  "prim": "address",
                              "annots": [
                                "%declareOwnership"
                              ]
                           }
                         ]
                      },
                      {  "prim": "or",
                         "args": [
                           {  "prim": "unit",
                              "annots": [
                                "%claimOwnership"
                              ]
                           },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "address",
                                   "annots": [
                                     "%token"
                                   ]
                                },
                                {  "prim": "address",
                                   "annots": [
                                     "%wallet"
                                   ]
                                }
                              ]
                              ,
                              "annots": [
                                "%setFeeReceiver"
                              ]
                           }
                         ]
                      }
                    ]
                 },
                 {  "prim": "or",
                    "args": [
                      {  "prim": "or",
                         "args": [
                           {  "prim": "address",
                              "annots": [
                                "%setDefaultFeeReceiver"
                              ]
                           },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "option",
                                   "args": [
                                     {  "prim": "key"  }
                                   ]
                                   ,
                                   "annots": [
                                     "%maker"
                                   ]
                                },
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "or",
                                                  "args": [
                                                    {  "prim": "unit"  },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "unit"  },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "unit"  },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                 ]
                                                              }
                                                            ]
                                                         }
                                                       ]
                                                    }
                                                  ]
                                                  ,
                                                  "annots": [
                                                    "%assetClass"
                                                  ]
                                               },
                                               {  "prim": "bytes",
                                                  "annots": [
                                                    "%assetData"
                                                  ]
                                               }
                                             ]
                                             ,
                                             "annots": [
                                               "%assetType"
                                             ]
                                          },
                                          {  "prim": "nat",
                                             "annots": [
                                               "%assetValue"
                                             ]
                                          }
                                        ]
                                        ,
                                        "annots": [
                                          "%makeAsset"
                                        ]
                                     },
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "option",
                                             "args": [
                                               {  "prim": "key"  }
                                             ]
                                             ,
                                             "annots": [
                                               "%taker"
                                             ]
                                          },
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "unit"  },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                 ]
                                                              }
                                                            ]
                                                            ,
                                                            "annots": [
                                                              "%assetClass"
                                                            ]
                                                         },
                                                         {  "prim": "bytes",
                                                            "annots": [
                                                              "%assetData"
                                                            ]
                                                         }
                                                       ]
                                                       ,
                                                       "annots": [
                                                         "%assetType"
                                                       ]
                                                    },
                                                    {  "prim": "nat",
                                                       "annots": [
                                                         "%assetValue"
                                                       ]
                                                    }
                                                  ]
                                                  ,
                                                  "annots": [
                                                    "%takeAsset"
                                                  ]
                                               },
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "nat",
                                                       "annots": [
                                                         "%salt"
                                                       ]
                                                    },
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "option",
                                                            "args": [
                                                              {  "prim": "timestamp"  }
                                                            ]
                                                            ,
                                                            "annots": [
                                                              "%start"
                                                            ]
                                                         },
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "option",
                                                                 "args": [
                                                                   {  "prim": "timestamp"  }
                                                                 ]
                                                                 ,
                                                                 "annots": [
                                                                   "%end"
                                                                 ]
                                                              },
                                                              {  "prim": "pair",
                                                                 "args": [
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%dataType"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%data"
                                                                   ]
                                                                   }
                                                                 ]
                                                              }
                                                            ]
                                                         }
                                                       ]
                                                    }
                                                  ]
                                               }
                                             ]
                                          }
                                        ]
                                     }
                                   ]
                                }
                              ]
                              ,
                              "annots": [
                                "%cancel"
                              ]
                           }
                         ]
                      },
                      {  "prim": "or",
                         "args": [
                           {  "prim": "bytes",
                              "annots": [
                                "%setMetadataUri"
                              ]
                           },
                           {  "prim": "bytes",
                              "annots": [
                                "%setMetadataUriValidator"
                              ]
                           }
                         ]
                      }
                    ]
                 }
               ]
            },
            {  "prim": "or",
               "args": [
                 {  "prim": "or",
                    "args": [
                      {  "prim": "or",
                         "args": [
                           {  "prim": "nat",
                              "annots": [
                                "%setProtocolFee"
                              ]
                           },
                           {  "prim": "address",
                              "annots": [
                                "%setRoyaltiesContract"
                              ]
                           }
                         ]
                      },
                      {  "prim": "or",
                         "args": [
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "unit"  },
                                     {  "prim": "or",
                                        "args": [
                                          {  "prim": "unit"  },
                                          {  "prim": "or",
                                             "args": [
                                               {  "prim": "unit"  },
                                               {  "prim": "or",
                                                  "args": [
                                                    {  "prim": "unit"  },
                                                    {  "prim": "bytes"  }
                                                  ]
                                               }
                                             ]
                                          }
                                        ]
                                     }
                                   ]
                                   ,
                                   "annots": [
                                     "%k"
                                   ]
                                },
                                {  "prim": "address",
                                   "annots": [
                                     "%v"
                                   ]
                                }
                              ]
                              ,
                              "annots": [
                                "%setAssetMatcher"
                              ]
                           },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "or",
                                        "args": [
                                          {  "prim": "unit"  },
                                          {  "prim": "or",
                                             "args": [
                                               {  "prim": "unit"  },
                                               {  "prim": "or",
                                                  "args": [
                                                    {  "prim": "unit"  },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "unit"  },
                                                         {  "prim": "bytes"  }
                                                       ]
                                                    }
                                                  ]
                                               }
                                             ]
                                          }
                                        ]
                                        ,
                                        "annots": [
                                          "%assetClass"
                                        ]
                                     },
                                     {  "prim": "bytes",
                                        "annots": [
                                          "%assetData"
                                        ]
                                     }
                                   ]
                                   ,
                                   "annots": [
                                     "%makeMatch"
                                   ]
                                },
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "or",
                                             "args": [
                                               {  "prim": "unit"  },
                                               {  "prim": "or",
                                                  "args": [
                                                    {  "prim": "unit"  },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "unit"  },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "unit"  },
                                                              {  "prim": "bytes"  }
                                                            ]
                                                         }
                                                       ]
                                                    }
                                                  ]
                                               }
                                             ]
                                             ,
                                             "annots": [
                                               "%assetClass"
                                             ]
                                          },
                                          {  "prim": "bytes",
                                             "annots": [
                                               "%assetData"
                                             ]
                                          }
                                        ]
                                        ,
                                        "annots": [
                                          "%takeMatch"
                                        ]
                                     },
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "nat",
                                                  "annots": [
                                                    "%fr_makeValue"
                                                  ]
                                               },
                                               {  "prim": "nat",
                                                  "annots": [
                                                    "%fr_takeValue"
                                                  ]
                                               }
                                             ]
                                             ,
                                             "annots": [
                                               "%ifill"
                                             ]
                                          },
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "option",
                                                       "args": [
                                                         {  "prim": "key"  }
                                                       ]
                                                       ,
                                                       "annots": [
                                                         "%maker"
                                                       ]
                                                    },
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "pair",
                                                                 "args": [
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetClass"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%assetData"
                                                                   ]
                                                                   }
                                                                 ]
                                                                 ,
                                                                 "annots": [
                                                                   "%assetType"
                                                                 ]
                                                              },
                                                              {  "prim": "nat",
                                                                 "annots": [
                                                                   "%assetValue"
                                                                 ]
                                                              }
                                                            ]
                                                            ,
                                                            "annots": [
                                                              "%makeAsset"
                                                            ]
                                                         },
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "option",
                                                                 "args": [
                                                                   {  "prim": "key"  }
                                                                 ]
                                                                 ,
                                                                 "annots": [
                                                                   "%taker"
                                                                 ]
                                                              },
                                                              {  "prim": "pair",
                                                                 "args": [
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetClass"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%assetData"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetType"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%assetValue"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%takeAsset"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [
                                                                     "%salt"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "option",
                                                                   "args": [

                                                                   {  "prim": "timestamp"  }
                                                                   ]
                                                                   ,
                                                                   "annots": [
                                                                     "%start"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "option",
                                                                   "args": [

                                                                   {  "prim": "timestamp"  }
                                                                   ]
                                                                   ,
                                                                   "annots": [
                                                                     "%end"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%dataType"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%data"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                 ]
                                                              }
                                                            ]
                                                         }
                                                       ]
                                                    }
                                                  ]
                                                  ,
                                                  "annots": [
                                                    "%leftOrder"
                                                  ]
                                               },
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "option",
                                                            "args": [
                                                              {  "prim": "key"  }
                                                            ]
                                                            ,
                                                            "annots": [
                                                              "%maker"
                                                            ]
                                                         },
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "pair",
                                                                 "args": [
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetClass"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%assetData"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetType"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%assetValue"
                                                                   ]
                                                                   }
                                                                 ]
                                                                 ,
                                                                 "annots": [
                                                                   "%makeAsset"
                                                                 ]
                                                              },
                                                              {  "prim": "pair",
                                                                 "args": [
                                                                   {
                                                                   "prim": "option",
                                                                   "args": [

                                                                   {  "prim": "key"  }
                                                                   ]
                                                                   ,
                                                                   "annots": [
                                                                     "%taker"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetClass"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%assetData"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetType"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%assetValue"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%takeAsset"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [
                                                                     "%salt"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "option",
                                                                   "args": [

                                                                   {  "prim": "timestamp"  }
                                                                   ]
                                                                   ,
                                                                   "annots": [
                                                                     "%start"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "option",
                                                                   "args": [

                                                                   {  "prim": "timestamp"  }
                                                                   ]
                                                                   ,
                                                                   "annots": [
                                                                     "%end"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%dataType"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%data"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                 ]
                                                              }
                                                            ]
                                                         }
                                                       ]
                                                       ,
                                                       "annots": [
                                                         "%rightOrder"
                                                       ]
                                                    },
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "nat",
                                                            "annots": [
                                                              "%feeSide"
                                                            ]
                                                         },
                                                         {  "prim": "list",
                                                            "args": [
                                                              {  "prim": "pair",
                                                                 "args": [
                                                                   {
                                                                   "prim": "address",
                                                                   "annots": [

                                                                   "%partAccount"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%partValue"
                                                                   ]
                                                                   }
                                                                 ]
                                                              }
                                                            ]
                                                            ,
                                                            "annots": [
                                                              "%iroyalties"
                                                            ]
                                                         }
                                                       ]
                                                    }
                                                  ]
                                               }
                                             ]
                                          }
                                        ]
                                     }
                                   ]
                                }
                              ]
                              ,
                              "annots": [
                                "%doTransfers"
                              ]
                           }
                         ]
                      }
                    ]
                 },
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "pair",
                         "args": [
                           {  "prim": "option",
                              "args": [
                                {  "prim": "key"  }
                              ]
                              ,
                              "annots": [
                                "%maker"
                              ]
                           },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "or",
                                             "args": [
                                               {  "prim": "unit"  },
                                               {  "prim": "or",
                                                  "args": [
                                                    {  "prim": "unit"  },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "unit"  },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "unit"  },
                                                              {  "prim": "bytes"  }
                                                            ]
                                                         }
                                                       ]
                                                    }
                                                  ]
                                               }
                                             ]
                                             ,
                                             "annots": [
                                               "%assetClass"
                                             ]
                                          },
                                          {  "prim": "bytes",
                                             "annots": [
                                               "%assetData"
                                             ]
                                          }
                                        ]
                                        ,
                                        "annots": [
                                          "%assetType"
                                        ]
                                     },
                                     {  "prim": "nat",
                                        "annots": [
                                          "%assetValue"
                                        ]
                                     }
                                   ]
                                   ,
                                   "annots": [
                                     "%makeAsset"
                                   ]
                                },
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "option",
                                        "args": [
                                          {  "prim": "key"  }
                                        ]
                                        ,
                                        "annots": [
                                          "%taker"
                                        ]
                                     },
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "unit"  },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "unit"  },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                 ]
                                                              }
                                                            ]
                                                         }
                                                       ]
                                                       ,
                                                       "annots": [
                                                         "%assetClass"
                                                       ]
                                                    },
                                                    {  "prim": "bytes",
                                                       "annots": [
                                                         "%assetData"
                                                       ]
                                                    }
                                                  ]
                                                  ,
                                                  "annots": [
                                                    "%assetType"
                                                  ]
                                               },
                                               {  "prim": "nat",
                                                  "annots": [
                                                    "%assetValue"
                                                  ]
                                               }
                                             ]
                                             ,
                                             "annots": [
                                               "%takeAsset"
                                             ]
                                          },
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "nat",
                                                  "annots": [
                                                    "%salt"
                                                  ]
                                               },
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "option",
                                                       "args": [
                                                         {  "prim": "timestamp"  }
                                                       ]
                                                       ,
                                                       "annots": [
                                                         "%start"
                                                       ]
                                                    },
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "option",
                                                            "args": [
                                                              {  "prim": "timestamp"  }
                                                            ]
                                                            ,
                                                            "annots": [
                                                              "%end"
                                                            ]
                                                         },
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "bytes",
                                                                 "annots": [
                                                                   "%dataType"
                                                                 ]
                                                              },
                                                              {  "prim": "bytes",
                                                                 "annots": [
                                                                   "%data"
                                                                 ]
                                                              }
                                                            ]
                                                         }
                                                       ]
                                                    }
                                                  ]
                                               }
                                             ]
                                          }
                                        ]
                                     }
                                   ]
                                }
                              ]
                           }
                         ]
                         ,
                         "annots": [
                           "%orderLeft"
                         ]
                      },
                      {  "prim": "pair",
                         "args": [
                           {  "prim": "option",
                              "args": [
                                {  "prim": "signature"  }
                              ]
                              ,
                              "annots": [
                                "%signatureLeft"
                              ]
                           },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "option",
                                        "args": [
                                          {  "prim": "key"  }
                                        ]
                                        ,
                                        "annots": [
                                          "%maker"
                                        ]
                                     },
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "unit"  },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "unit"  },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                 ]
                                                              }
                                                            ]
                                                         }
                                                       ]
                                                       ,
                                                       "annots": [
                                                         "%assetClass"
                                                       ]
                                                    },
                                                    {  "prim": "bytes",
                                                       "annots": [
                                                         "%assetData"
                                                       ]
                                                    }
                                                  ]
                                                  ,
                                                  "annots": [
                                                    "%assetType"
                                                  ]
                                               },
                                               {  "prim": "nat",
                                                  "annots": [
                                                    "%assetValue"
                                                  ]
                                               }
                                             ]
                                             ,
                                             "annots": [
                                               "%makeAsset"
                                             ]
                                          },
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "option",
                                                  "args": [
                                                    {  "prim": "key"  }
                                                  ]
                                                  ,
                                                  "annots": [
                                                    "%taker"
                                                  ]
                                               },
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                 ]
                                                                 ,
                                                                 "annots": [
                                                                   "%assetClass"
                                                                 ]
                                                              },
                                                              {  "prim": "bytes",
                                                                 "annots": [
                                                                   "%assetData"
                                                                 ]
                                                              }
                                                            ]
                                                            ,
                                                            "annots": [
                                                              "%assetType"
                                                            ]
                                                         },
                                                         {  "prim": "nat",
                                                            "annots": [
                                                              "%assetValue"
                                                            ]
                                                         }
                                                       ]
                                                       ,
                                                       "annots": [
                                                         "%takeAsset"
                                                       ]
                                                    },
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "nat",
                                                            "annots": [
                                                              "%salt"
                                                            ]
                                                         },
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "option",
                                                                 "args": [
                                                                   {  "prim": "timestamp"  }
                                                                 ]
                                                                 ,
                                                                 "annots": [
                                                                   "%start"
                                                                 ]
                                                              },
                                                              {  "prim": "pair",
                                                                 "args": [
                                                                   {
                                                                   "prim": "option",
                                                                   "args": [

                                                                   {  "prim": "timestamp"  }
                                                                   ]
                                                                   ,
                                                                   "annots": [
                                                                     "%end"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%dataType"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%data"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                 ]
                                                              }
                                                            ]
                                                         }
                                                       ]
                                                    }
                                                  ]
                                               }
                                             ]
                                          }
                                        ]
                                     }
                                   ]
                                   ,
                                   "annots": [
                                     "%orderRight"
                                   ]
                                },
                                {  "prim": "option",
                                   "args": [
                                     {  "prim": "signature"  }
                                   ]
                                   ,
                                   "annots": [
                                     "%signatureRight"
                                   ]
                                }
                              ]
                           }
                         ]
                      }
                    ]
                    ,
                    "annots": [
                      "%matchOrders"
                    ]
                 }
               ]
            }
          ]
       }
     ]
  },
  {  "prim": "code",
     "args": [
       [  {  "prim": "LAMBDA",
             "args": [
               {  "prim": "pair",
                  "args": [
                    {  "prim": "address"  },
                    {  "prim": "pair",
                       "args": [
                         {  "prim": "map",
                            "args": [
                              {  "prim": "address"  },
                              {  "prim": "address"  }
                            ]
                         },
                         {  "prim": "option",
                            "args": [
                              {  "prim": "address"  }
                            ]
                         }
                       ]
                    }
                  ]
               },
               {  "prim": "address"  },
               [  {  "prim": "UNPAIR"  },
               {  "prim": "SWAP"  },
               {  "prim": "UNPAIR"  },
               {  "prim": "SWAP"  },
               {  "prim": "PUSH",
                  "args": [
                    {  "prim": "unit"  },
                    {  "prim": "Unit"  }
                  ]
               },
               {  "prim": "DIG",
                  "args": [
                    {  "int": "1"  }
                  ]
               },
               {  "prim": "DUP"  },
               {  "prim": "DUG",
                  "args": [
                    {  "int": "2"  }
                  ]
               },
               {  "prim": "IF_NONE",
                  "args": [
                    [  {  "prim": "DIG",
                          "args": [
                            {  "int": "3"  }
                          ]
                    },
                    {  "prim": "DUP"  },
                    {  "prim": "DUG",
                       "args": [
                         {  "int": "4"  }
                       ]
                    }  ],
                    [  {  "prim": "DIG",
                          "args": [
                            {  "int": "3"  }
                          ]
                    },
                    {  "prim": "DUP"  },
                    {  "prim": "DUG",
                       "args": [
                         {  "int": "4"  }
                       ]
                    },
                    {  "prim": "DIG",
                       "args": [
                         {  "int": "1"  }
                       ]
                    },
                    {  "prim": "DUP"  },
                    {  "prim": "DUG",
                       "args": [
                         {  "int": "2"  }
                       ]
                    },
                    {  "prim": "GET"  },
                    {  "prim": "IF_NONE",
                       "args": [
                         [  {  "prim": "DIG",
                               "args": [
                                 {  "int": "4"  }
                               ]
                         },
                         {  "prim": "DUP"  },
                         {  "prim": "DUG",
                            "args": [
                              {  "int": "5"  }
                            ]
                         }  ],
                         [    ]
                       ]
                    },
                    {  "prim": "SWAP"  },
                    {  "prim": "DROP",
                       "args": [
                         {  "int": "1"  }
                       ]
                    }  ]
                  ]
               },
               {  "prim": "SWAP"  },
               {  "prim": "DROP",
                  "args": [
                    {  "int": "1"  }
                  ]
               },
               {  "prim": "DUG",
                  "args": [
                    {  "int": "3"  }
                  ]
               },
               {  "prim": "DROP",
                  "args": [
                    {  "int": "3"  }
                  ]
               }  ]
             ]
       },
       {  "prim": "LAMBDA",
          "args": [
            {  "prim": "pair",
               "args": [
                 {  "prim": "address"  },
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "list",
                         "args": [
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "address",
                                   "annots": [
                                     "%partAccount"
                                   ]
                                },
                                {  "prim": "nat",
                                   "annots": [
                                     "%partValue"
                                   ]
                                }
                              ]
                           }
                         ]
                         ,
                         "annots": [
                           "%payouts"
                         ]
                      },
                      {  "prim": "list",
                         "args": [
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "address",
                                   "annots": [
                                     "%partAccount"
                                   ]
                                },
                                {  "prim": "nat",
                                   "annots": [
                                     "%partValue"
                                   ]
                                }
                              ]
                           }
                         ]
                         ,
                         "annots": [
                           "%originFees"
                         ]
                      }
                    ]
                 }
               ]
            },
            {  "prim": "pair",
               "args": [
                 {  "prim": "list",
                    "args": [
                      {  "prim": "pair",
                         "args": [
                           {  "prim": "address",
                              "annots": [
                                "%partAccount"
                              ]
                           },
                           {  "prim": "nat",
                              "annots": [
                                "%partValue"
                              ]
                           }
                         ]
                      }
                    ]
                    ,
                    "annots": [
                      "%payouts"
                    ]
                 },
                 {  "prim": "list",
                    "args": [
                      {  "prim": "pair",
                         "args": [
                           {  "prim": "address",
                              "annots": [
                                "%partAccount"
                              ]
                           },
                           {  "prim": "nat",
                              "annots": [
                                "%partValue"
                              ]
                           }
                         ]
                      }
                    ]
                    ,
                    "annots": [
                      "%originFees"
                    ]
                 }
               ]
            },
            [  {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "unit"  },
                 {  "prim": "Unit"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "UNPAIR"  },
            {  "prim": "DROP",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "NIL",
               "args": [
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "address",
                         "annots": [
                           "%partAccount"
                         ]
                      },
                      {  "prim": "nat",
                         "annots": [
                           "%partValue"
                         ]
                      }
                    ]
                 }
               ]
            },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "nat"  },
                 {  "int": "10000"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "CONS"  },
            {  "prim": "PAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "DROP",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DUG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "2"  }
               ]
            }  ]
          ]
       },
       {  "prim": "LAMBDA",
          "args": [
            {  "prim": "pair",
               "args": [
                 {  "prim": "bytes"  },
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "pair",
                         "args": [
                           {  "prim": "option",
                              "args": [
                                {  "prim": "key"  }
                              ]
                              ,
                              "annots": [
                                "%maker"
                              ]
                           },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "or",
                                             "args": [
                                               {  "prim": "unit"  },
                                               {  "prim": "or",
                                                  "args": [
                                                    {  "prim": "unit"  },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "unit"  },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "unit"  },
                                                              {  "prim": "bytes"  }
                                                            ]
                                                         }
                                                       ]
                                                    }
                                                  ]
                                               }
                                             ]
                                             ,
                                             "annots": [
                                               "%assetClass"
                                             ]
                                          },
                                          {  "prim": "bytes",
                                             "annots": [
                                               "%assetData"
                                             ]
                                          }
                                        ]
                                        ,
                                        "annots": [
                                          "%assetType"
                                        ]
                                     },
                                     {  "prim": "nat",
                                        "annots": [
                                          "%assetValue"
                                        ]
                                     }
                                   ]
                                   ,
                                   "annots": [
                                     "%makeAsset"
                                   ]
                                },
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "option",
                                        "args": [
                                          {  "prim": "key"  }
                                        ]
                                        ,
                                        "annots": [
                                          "%taker"
                                        ]
                                     },
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "unit"  },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "unit"  },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                 ]
                                                              }
                                                            ]
                                                         }
                                                       ]
                                                       ,
                                                       "annots": [
                                                         "%assetClass"
                                                       ]
                                                    },
                                                    {  "prim": "bytes",
                                                       "annots": [
                                                         "%assetData"
                                                       ]
                                                    }
                                                  ]
                                                  ,
                                                  "annots": [
                                                    "%assetType"
                                                  ]
                                               },
                                               {  "prim": "nat",
                                                  "annots": [
                                                    "%assetValue"
                                                  ]
                                               }
                                             ]
                                             ,
                                             "annots": [
                                               "%takeAsset"
                                             ]
                                          },
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "nat",
                                                  "annots": [
                                                    "%salt"
                                                  ]
                                               },
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "option",
                                                       "args": [
                                                         {  "prim": "timestamp"  }
                                                       ]
                                                       ,
                                                       "annots": [
                                                         "%start"
                                                       ]
                                                    },
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "option",
                                                            "args": [
                                                              {  "prim": "timestamp"  }
                                                            ]
                                                            ,
                                                            "annots": [
                                                              "%end"
                                                            ]
                                                         },
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "bytes",
                                                                 "annots": [
                                                                   "%dataType"
                                                                 ]
                                                              },
                                                              {  "prim": "bytes",
                                                                 "annots": [
                                                                   "%data"
                                                                 ]
                                                              }
                                                            ]
                                                         }
                                                       ]
                                                    }
                                                  ]
                                               }
                                             ]
                                          }
                                        ]
                                     }
                                   ]
                                }
                              ]
                           }
                         ]
                      },
                      {  "prim": "lambda",
                         "args": [
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "address"  },
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "list",
                                        "args": [
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "address",
                                                  "annots": [
                                                    "%partAccount"
                                                  ]
                                               },
                                               {  "prim": "nat",
                                                  "annots": [
                                                    "%partValue"
                                                  ]
                                               }
                                             ]
                                          }
                                        ]
                                        ,
                                        "annots": [
                                          "%payouts"
                                        ]
                                     },
                                     {  "prim": "list",
                                        "args": [
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "address",
                                                  "annots": [
                                                    "%partAccount"
                                                  ]
                                               },
                                               {  "prim": "nat",
                                                  "annots": [
                                                    "%partValue"
                                                  ]
                                               }
                                             ]
                                          }
                                        ]
                                        ,
                                        "annots": [
                                          "%originFees"
                                        ]
                                     }
                                   ]
                                }
                              ]
                           },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "list",
                                   "args": [
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "address",
                                             "annots": [
                                               "%partAccount"
                                             ]
                                          },
                                          {  "prim": "nat",
                                             "annots": [
                                               "%partValue"
                                             ]
                                          }
                                        ]
                                     }
                                   ]
                                   ,
                                   "annots": [
                                     "%payouts"
                                   ]
                                },
                                {  "prim": "list",
                                   "args": [
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "address",
                                             "annots": [
                                               "%partAccount"
                                             ]
                                          },
                                          {  "prim": "nat",
                                             "annots": [
                                               "%partValue"
                                             ]
                                          }
                                        ]
                                     }
                                   ]
                                   ,
                                   "annots": [
                                     "%originFees"
                                   ]
                                }
                              ]
                           }
                         ]
                      }
                    ]
                 }
               ]
            },
            {  "prim": "pair",
               "args": [
                 {  "prim": "list",
                    "args": [
                      {  "prim": "pair",
                         "args": [
                           {  "prim": "address",
                              "annots": [
                                "%partAccount"
                              ]
                           },
                           {  "prim": "nat",
                              "annots": [
                                "%partValue"
                              ]
                           }
                         ]
                      }
                    ]
                    ,
                    "annots": [
                      "%payouts"
                    ]
                 },
                 {  "prim": "list",
                    "args": [
                      {  "prim": "pair",
                         "args": [
                           {  "prim": "address",
                              "annots": [
                                "%partAccount"
                              ]
                           },
                           {  "prim": "nat",
                              "annots": [
                                "%partValue"
                              ]
                           }
                         ]
                      }
                    ]
                    ,
                    "annots": [
                      "%originFees"
                    ]
                 }
               ]
            },
            [  {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "unit"  },
                 {  "prim": "Unit"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "CAR",
               "args": [
                 {  "int": "0"  }
               ]
            },
            {  "prim": "IF_NONE",
               "args": [
                 [  {  "prim": "PUSH",
                       "args": [
                         {  "prim": "string"  },
                         {  "string": "NotFound"  }
                       ]
                 },
                 {  "prim": "FAILWITH"  }  ],
                 [    ]
               ]
            },
            {  "prim": "HASH_KEY"  },
            {  "prim": "IMPLICIT_ACCOUNT"  },
            {  "prim": "ADDRESS"  },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "string"  },
                 {  "string": "V1"  }
               ]
            },
            {  "prim": "PACK"  },
            {  "prim": "KECCAK"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "CAR",
               "args": [
                 {  "int": "7"  }
               ]
            },
            {  "prim": "COMPARE"  },
            {  "prim": "EQ"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "DIG",
                       "args": [
                         {  "int": "3"  }
                       ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "4"  }
                    ]
                 },
                 {  "prim": "CDR",
                    "args": [
                      {  "int": "8"  }
                    ]
                 },
                 {  "prim": "UNPACK",
                    "args": [
                      {  "prim": "pair",
                         "args": [
                           {  "prim": "list",
                              "args": [
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "address"  },
                                     {  "prim": "nat"  }
                                   ]
                                }
                              ]
                           },
                           {  "prim": "list",
                              "args": [
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "address"  },
                                     {  "prim": "nat"  }
                                   ]
                                }
                              ]
                           }
                         ]
                      }
                    ]
                 },
                 {  "prim": "IF_NONE",
                    "args": [
                      [  {  "prim": "PUSH",
                            "args": [
                              {  "prim": "string"  },
                              {  "string": "unable to unpack DataV1"  }
                            ]
                      },
                      {  "prim": "FAILWITH"  }  ],
                      [  {  "prim": "DUP"  },
                      {  "prim": "PUSH",
                         "args": [
                           {  "prim": "nat"  },
                           {  "int": "0"  }
                         ]
                      },
                      {  "prim": "DIG",
                         "args": [
                           {  "int": "2"  }
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "3"  }
                         ]
                      },
                      {  "prim": "CAR",
                         "args": [
                           {  "int": "0"  }
                         ]
                      },
                      {  "prim": "SIZE"  },
                      {  "prim": "COMPARE"  },
                      {  "prim": "EQ"  },
                      {  "prim": "IF",
                         "args": [
                           [  {  "prim": "DIG",
                                 "args": [
                                   {  "int": "4"  }
                                 ]
                           },
                           {  "prim": "DUP"  },
                           {  "prim": "DUG",
                              "args": [
                                {  "int": "5"  }
                              ]
                           },
                           {  "prim": "DIG",
                              "args": [
                                {  "int": "2"  }
                              ]
                           },
                           {  "prim": "DUP"  },
                           {  "prim": "DUG",
                              "args": [
                                {  "int": "3"  }
                              ]
                           },
                           {  "prim": "DIG",
                              "args": [
                                {  "int": "4"  }
                              ]
                           },
                           {  "prim": "DUP"  },
                           {  "prim": "DUG",
                              "args": [
                                {  "int": "5"  }
                              ]
                           },
                           {  "prim": "PAIR"  },
                           {  "prim": "EXEC"  },
                           {  "prim": "SWAP"  },
                           {  "prim": "DROP",
                              "args": [
                                {  "int": "1"  }
                              ]
                           }  ],
                           [    ]
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DIP",
                         "args": [
                           {  "int": "1"  },
                           [  {  "prim": "DIG",
                                 "args": [
                                   {  "int": "3"  }
                                 ]
                           },
                           {  "prim": "DROP",
                              "args": [
                                {  "int": "1"  }
                              ]
                           }  ]
                         ]
                      },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "3"  }
                         ]
                      },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "2"  }
                         ]
                      }  ]
                    ]
                 }  ],
                 [  {  "prim": "PUSH",
                       "args": [
                         {  "prim": "bytes"  },
                         {  "bytes": "ffffffff"  }
                       ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "4"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "5"  }
                    ]
                 },
                 {  "prim": "CAR",
                    "args": [
                      {  "int": "7"  }
                    ]
                 },
                 {  "prim": "COMPARE"  },
                 {  "prim": "EQ"  },
                 {  "prim": "IF",
                    "args": [
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "2"  }
                            ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "3"  }
                         ]
                      },
                      {  "prim": "NIL",
                         "args": [
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "address",
                                   "annots": [
                                     "%partAccount"
                                   ]
                                },
                                {  "prim": "nat",
                                   "annots": [
                                     "%partValue"
                                   ]
                                }
                              ]
                           }
                         ]
                      },
                      {  "prim": "NIL",
                         "args": [
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "address",
                                   "annots": [
                                     "%partAccount"
                                   ]
                                },
                                {  "prim": "nat",
                                   "annots": [
                                     "%partValue"
                                   ]
                                }
                              ]
                           }
                         ]
                      },
                      {  "prim": "PAIR"  },
                      {  "prim": "DIG",
                         "args": [
                           {  "int": "2"  }
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "3"  }
                         ]
                      },
                      {  "prim": "PAIR"  },
                      {  "prim": "EXEC"  },
                      {  "prim": "DIP",
                         "args": [
                           {  "int": "1"  },
                           [  {  "prim": "DIG",
                                 "args": [
                                   {  "int": "1"  }
                                 ]
                           },
                           {  "prim": "DROP",
                              "args": [
                                {  "int": "1"  }
                              ]
                           }  ]
                         ]
                      },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ],
                      [  {  "prim": "PUSH",
                            "args": [
                              {  "prim": "string"  },
                              {  "string": "Unknown Order data type"  }
                            ]
                      },
                      {  "prim": "FAILWITH"  }  ]
                    ]
                 }  ]
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DUG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "3"  }
               ]
            }  ]
          ]
       },
       {  "prim": "LAMBDA",
          "args": [
            {  "prim": "pair",
               "args": [
                 {  "prim": "nat"  },
                 {  "prim": "nat"  }
               ]
            },
            {  "prim": "nat"  },
            [  {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "unit"  },
                 {  "prim": "Unit"  }
               ]
            },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "nat"  },
                 {  "int": "1"  }
               ]
            },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "nat"  },
                 {  "int": "10000"  }
               ]
            },
            {  "prim": "INT"  },
            {  "prim": "PAIR"  },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "nat"  },
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "MUL"  },
            {  "prim": "INT"  },
            {  "prim": "PAIR"  },
            {  "prim": "DIP",
               "args": [
                 {  "int": "1"  },
                 [  {  "prim": "UNPAIR"  }  ]
               ]
            },
            {  "prim": "UNPAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "MUL"  },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "nat"  },
                 {  "int": "0"  }
               ]
            },
            {  "prim": "COMPARE"  },
            {  "prim": "EQ"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "PUSH",
                       "args": [
                         {  "prim": "string"  },
                         {  "string": "DivByZero"  }
                       ]
                 },
                 {  "prim": "FAILWITH"  }  ],
                 [    ]
               ]
            },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "int"  },
                 {  "int": "0"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "COMPARE"  },
            {  "prim": "GE"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "INT"  }  ],
                 [  {  "prim": "NEG"  }  ]
               ]
            },
            {  "prim": "MUL"  },
            {  "prim": "DIP",
               "args": [
                 {  "int": "1"  },
                 [  {  "prim": "MUL"  },
                 {  "prim": "ABS"  }  ]
               ]
            },
            {  "prim": "EDIV"  },
            {  "prim": "IF_NONE",
               "args": [
                 [  {  "prim": "PUSH",
                       "args": [
                         {  "prim": "string"  },
                         {  "string": "DivByZero"  }
                       ]
                 },
                 {  "prim": "FAILWITH"  }  ],
                 [  {  "prim": "CAR",
                       "args": [
                         {  "int": "0"  }
                       ]
                 }  ]
               ]
            },
            {  "prim": "ABS"  },
            {  "prim": "SWAP"  },
            {  "prim": "DROP",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DUG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "2"  }
               ]
            }  ]
          ]
       },
       {  "prim": "LAMBDA",
          "args": [
            {  "prim": "pair",
               "args": [
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "pair",
                         "args": [
                           {  "prim": "or",
                              "args": [
                                {  "prim": "unit"  },
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "unit"  },
                                     {  "prim": "or",
                                        "args": [
                                          {  "prim": "unit"  },
                                          {  "prim": "or",
                                             "args": [
                                               {  "prim": "unit"  },
                                               {  "prim": "bytes"  }
                                             ]
                                          }
                                        ]
                                     }
                                   ]
                                }
                              ]
                              ,
                              "annots": [
                                "%assetClass"
                              ]
                           },
                           {  "prim": "bytes",
                              "annots": [
                                "%assetData"
                              ]
                           }
                         ]
                         ,
                         "annots": [
                           "%assetType"
                         ]
                      },
                      {  "prim": "nat",
                         "annots": [
                           "%assetValue"
                         ]
                      }
                    ]
                 },
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "address"  },
                      {  "prim": "address"  }
                    ]
                 }
               ]
            },
            {  "prim": "operation"  },
            [  {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "unit"  },
                 {  "prim": "Unit"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "CAR",
               "args": [
                 {  "int": "0"  }
               ]
            },
            {  "prim": "CAR",
               "args": [
                 {  "int": "0"  }
               ]
            },
            {  "prim": "IF_LEFT",
               "args": [
                 [  {  "prim": "DIG",
                       "args": [
                         {  "int": "2"  }
                       ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "CONTRACT",
                    "args": [
                      {  "prim": "unit"  }
                    ]
                 },
                 {  "prim": "IF_NONE",
                    "args": [
                      [  {  "prim": "PUSH",
                            "args": [
                              {  "prim": "string"  },
                              {  "string": "NotFound"  }
                            ]
                      },
                      {  "prim": "FAILWITH"  }  ],
                      [    ]
                    ]
                 },
                 {  "prim": "PUSH",
                    "args": [
                      {  "prim": "mutez"  },
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "PUSH",
                    "args": [
                      {  "prim": "nat"  },
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "7"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "8"  }
                    ]
                 },
                 {  "prim": "CDR",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "INT"  },
                 {  "prim": "PAIR"  },
                 {  "prim": "UNPAIR"  },
                 {  "prim": "ABS"  },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "MUL"  },
                 {  "prim": "EDIV"  },
                 {  "prim": "IF_NONE",
                    "args": [
                      [  {  "prim": "PUSH",
                            "args": [
                              {  "prim": "string"  },
                              {  "string": "DivByZero"  }
                            ]
                      },
                      {  "prim": "FAILWITH"  }  ],
                      [    ]
                    ]
                 },
                 {  "prim": "CAR",
                    "args": [
                      {  "int": "0"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "PUSH",
                    "args": [
                      {  "prim": "unit"  },
                      {  "prim": "Unit"  }
                    ]
                 },
                 {  "prim": "TRANSFER_TOKENS"  },
                 {  "prim": "DUP"  },
                 {  "prim": "DIP",
                    "args": [
                      {  "int": "1"  },
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "4"  }
                            ]
                      },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ]
                    ]
                 },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "4"  }
                    ]
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "4"  }
                    ]
                 }  ],
                 [  {  "prim": "DUP"  },
                 {  "prim": "IF_LEFT",
                    "args": [
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "5"  }
                            ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "6"  }
                         ]
                      },
                      {  "prim": "CAR",
                         "args": [
                           {  "int": "0"  }
                         ]
                      },
                      {  "prim": "CDR",
                         "args": [
                           {  "int": "1"  }
                         ]
                      },
                      {  "prim": "UNPACK",
                         "args": [
                           {  "prim": "address"  }
                         ]
                      },
                      {  "prim": "IF_NONE",
                         "args": [
                           [  {  "prim": "PUSH",
                                 "args": [
                                   {  "prim": "string"  },
                                   {  "string": "cannot unpack addr fa_1_2"  }
                                 ]
                           },
                           {  "prim": "FAILWITH"  }  ],
                           [    ]
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "CONTRACT",
                         "args": [
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "address"  },
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "address"  },
                                     {  "prim": "nat"  }
                                   ]
                                }
                              ]
                           }
                         ]
                         ,
                         "annots": [
                           "%transfer"
                         ]
                      },
                      {  "prim": "IF_NONE",
                         "args": [
                           [  {  "prim": "PUSH",
                                 "args": [
                                   {  "prim": "string"  },
                                   {  "string": "entry transfer FA_1_2 not found"  }
                                 ]
                           },
                           {  "prim": "FAILWITH"  }  ],
                           [    ]
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "PUSH",
                         "args": [
                           {  "prim": "mutez"  },
                           {  "int": "0"  }
                         ]
                      },
                      {  "prim": "DIG",
                         "args": [
                           {  "int": "9"  }
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "10"  }
                         ]
                      },
                      {  "prim": "CDR",
                         "args": [
                           {  "int": "1"  }
                         ]
                      },
                      {  "prim": "DIG",
                         "args": [
                           {  "int": "8"  }
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "9"  }
                         ]
                      },
                      {  "prim": "PAIR"  },
                      {  "prim": "DIG",
                         "args": [
                           {  "int": "9"  }
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "10"  }
                         ]
                      },
                      {  "prim": "PAIR"  },
                      {  "prim": "TRANSFER_TOKENS"  },
                      {  "prim": "DIP",
                         "args": [
                           {  "int": "1"  },
                           [  {  "prim": "DIG",
                                 "args": [
                                   {  "int": "4"  }
                                 ]
                           },
                           {  "prim": "DROP",
                              "args": [
                                {  "int": "1"  }
                              ]
                           }  ]
                         ]
                      },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "4"  }
                         ]
                      },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "3"  }
                         ]
                      }  ],
                      [  {  "prim": "DUP"  },
                      {  "prim": "IF_LEFT",
                         "args": [
                           [  {  "prim": "DIG",
                                 "args": [
                                   {  "int": "6"  }
                                 ]
                           },
                           {  "prim": "DUP"  },
                           {  "prim": "DUG",
                              "args": [
                                {  "int": "7"  }
                              ]
                           },
                           {  "prim": "CAR",
                              "args": [
                                {  "int": "0"  }
                              ]
                           },
                           {  "prim": "CDR",
                              "args": [
                                {  "int": "1"  }
                              ]
                           },
                           {  "prim": "UNPACK",
                              "args": [
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "address"  },
                                     {  "prim": "nat"  }
                                   ]
                                }
                              ]
                           },
                           {  "prim": "IF_NONE",
                              "args": [
                                [  {  "prim": "PUSH",
                                      "args": [
                                        {  "prim": "string"  },
                                        {  "string": "cannot unpack addr fa_2"  }
                                      ]
                                },
                                {  "prim": "FAILWITH"  }  ],
                                [    ]
                              ]
                           },
                           {  "prim": "DUP"  },
                           {  "prim": "CAR",
                              "args": [
                                {  "int": "0"  }
                              ]
                           },
                           {  "prim": "CONTRACT",
                              "args": [
                                {  "prim": "list",
                                   "args": [
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "address"  },
                                          {  "prim": "list",
                                             "args": [
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "address"  },
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "nat"  },
                                                         {  "prim": "nat"  }
                                                       ]
                                                    }
                                                  ]
                                               }
                                             ]
                                          }
                                        ]
                                     }
                                   ]
                                }
                              ]
                              ,
                              "annots": [
                                "%transfer"
                              ]
                           },
                           {  "prim": "IF_NONE",
                              "args": [
                                [  {  "prim": "PUSH",
                                      "args": [
                                        {  "prim": "string"  },
                                        {  "string": "entry transfer FA_2 not found"  }
                                      ]
                                },
                                {  "prim": "FAILWITH"  }  ],
                                [    ]
                              ]
                           },
                           {  "prim": "NIL",
                              "args": [
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "address"  },
                                     {  "prim": "list",
                                        "args": [
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "address"  },
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "nat"  },
                                                    {  "prim": "nat"  }
                                                  ]
                                               }
                                             ]
                                          }
                                        ]
                                     }
                                   ]
                                }
                              ]
                           },
                           {  "prim": "NIL",
                              "args": [
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "address"  },
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "nat"  },
                                          {  "prim": "nat"  }
                                        ]
                                     }
                                   ]
                                }
                              ]
                           },
                           {  "prim": "DIG",
                              "args": [
                                {  "int": "10"  }
                              ]
                           },
                           {  "prim": "DUP"  },
                           {  "prim": "DUG",
                              "args": [
                                {  "int": "11"  }
                              ]
                           },
                           {  "prim": "CDR",
                              "args": [
                                {  "int": "1"  }
                              ]
                           },
                           {  "prim": "DIG",
                              "args": [
                                {  "int": "4"  }
                              ]
                           },
                           {  "prim": "DUP"  },
                           {  "prim": "DUG",
                              "args": [
                                {  "int": "5"  }
                              ]
                           },
                           {  "prim": "CDR",
                              "args": [
                                {  "int": "1"  }
                              ]
                           },
                           {  "prim": "PAIR"  },
                           {  "prim": "DIG",
                              "args": [
                                {  "int": "9"  }
                              ]
                           },
                           {  "prim": "DUP"  },
                           {  "prim": "DUG",
                              "args": [
                                {  "int": "10"  }
                              ]
                           },
                           {  "prim": "PAIR"  },
                           {  "prim": "CONS"  },
                           {  "prim": "DIG",
                              "args": [
                                {  "int": "9"  }
                              ]
                           },
                           {  "prim": "DUP"  },
                           {  "prim": "DUG",
                              "args": [
                                {  "int": "10"  }
                              ]
                           },
                           {  "prim": "PAIR"  },
                           {  "prim": "CONS"  },
                           {  "prim": "DIG",
                              "args": [
                                {  "int": "1"  }
                              ]
                           },
                           {  "prim": "DUP"  },
                           {  "prim": "DUG",
                              "args": [
                                {  "int": "2"  }
                              ]
                           },
                           {  "prim": "PUSH",
                              "args": [
                                {  "prim": "mutez"  },
                                {  "int": "0"  }
                              ]
                           },
                           {  "prim": "DIG",
                              "args": [
                                {  "int": "2"  }
                              ]
                           },
                           {  "prim": "DUP"  },
                           {  "prim": "DUG",
                              "args": [
                                {  "int": "3"  }
                              ]
                           },
                           {  "prim": "TRANSFER_TOKENS"  },
                           {  "prim": "DIP",
                              "args": [
                                {  "int": "1"  },
                                [  {  "prim": "DIG",
                                      "args": [
                                        {  "int": "6"  }
                                      ]
                                },
                                {  "prim": "DROP",
                                   "args": [
                                     {  "int": "1"  }
                                   ]
                                }  ]
                              ]
                           },
                           {  "prim": "DUG",
                              "args": [
                                {  "int": "6"  }
                              ]
                           },
                           {  "prim": "DROP",
                              "args": [
                                {  "int": "4"  }
                              ]
                           }  ],
                           [  {  "prim": "DUP"  },
                           {  "prim": "IF_LEFT",
                              "args": [
                                [  {  "prim": "PUSH",
                                      "args": [
                                        {  "prim": "string"  },
                                        {  "string": "Unsupported"  }
                                      ]
                                },
                                {  "prim": "FAILWITH"  }  ],
                                [  {  "prim": "PUSH",
                                      "args": [
                                        {  "prim": "string"  },
                                        {  "string": "Unsupported"  }
                                      ]
                                },
                                {  "prim": "FAILWITH"  }  ]
                              ]
                           }  ]
                         ]
                      },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ]
                    ]
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
                    ]
                 }  ]
               ]
            },
            {  "prim": "DUG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "3"  }
               ]
            }  ]
          ]
       },
       {  "prim": "LAMBDA",
          "args": [
            {  "prim": "pair",
               "args": [
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "or",
                         "args": [
                           {  "prim": "unit"  },
                           {  "prim": "or",
                              "args": [
                                {  "prim": "unit"  },
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "unit"  },
                                     {  "prim": "or",
                                        "args": [
                                          {  "prim": "unit"  },
                                          {  "prim": "bytes"  }
                                        ]
                                     }
                                   ]
                                }
                              ]
                           }
                         ]
                         ,
                         "annots": [
                           "%assetClass"
                         ]
                      },
                      {  "prim": "bytes",
                         "annots": [
                           "%assetData"
                         ]
                      }
                    ]
                 },
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "nat"  },
                      {  "prim": "pair",
                         "args": [
                           {  "prim": "address"  },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "list",
                                   "args": [
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "address",
                                             "annots": [
                                               "%partAccount"
                                             ]
                                          },
                                          {  "prim": "nat",
                                             "annots": [
                                               "%partValue"
                                             ]
                                          }
                                        ]
                                     }
                                   ]
                                },
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "lambda",
                                        "args": [
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "unit"  },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                 ]
                                                              }
                                                            ]
                                                            ,
                                                            "annots": [
                                                              "%assetClass"
                                                            ]
                                                         },
                                                         {  "prim": "bytes",
                                                            "annots": [
                                                              "%assetData"
                                                            ]
                                                         }
                                                       ]
                                                       ,
                                                       "annots": [
                                                         "%assetType"
                                                       ]
                                                    },
                                                    {  "prim": "nat",
                                                       "annots": [
                                                         "%assetValue"
                                                       ]
                                                    }
                                                  ]
                                               },
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "address"  },
                                                    {  "prim": "address"  }
                                                  ]
                                               }
                                             ]
                                          },
                                          {  "prim": "operation"  }
                                        ]
                                     },
                                     {  "prim": "lambda",
                                        "args": [
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "nat"  },
                                               {  "prim": "nat"  }
                                             ]
                                          },
                                          {  "prim": "nat"  }
                                        ]
                                     }
                                   ]
                                }
                              ]
                           }
                         ]
                      }
                    ]
                 }
               ]
            },
            {  "prim": "list",
               "args": [
                 {  "prim": "operation"  }
               ]
            },
            [  {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "unit"  },
                 {  "prim": "Unit"  }
               ]
            },
            {  "prim": "NIL",
               "args": [
                 {  "prim": "operation"  }
               ]
            },
            {  "prim": "NIL",
               "args": [
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "address",
                         "annots": [
                           "%partAccount"
                         ]
                      },
                      {  "prim": "nat",
                         "annots": [
                           "%partValue"
                         ]
                      }
                    ]
                 }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "ITER",
               "args": [
                 [  {  "prim": "DIG",
                       "args": [
                         {  "int": "1"  }
                       ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "CONS"  },
                 {  "prim": "DIP",
                    "args": [
                      {  "int": "1"  },
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "1"  }
                            ]
                      },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ]
                    ]
                 },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
                    ]
                 }  ]
               ]
            },
            {  "prim": "IF_CONS",
               "args": [
                 [  {  "prim": "PUSH",
                       "args": [
                         {  "prim": "nat"  },
                         {  "int": "0"  }
                       ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "9"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "10"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "4"  }
                    ]
                 },
                 {  "prim": "ITER",
                    "args": [
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "7"  }
                            ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "8"  }
                         ]
                      },
                      {  "prim": "DIG",
                         "args": [
                           {  "int": "1"  }
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "2"  }
                         ]
                      },
                      {  "prim": "CDR",
                         "args": [
                           {  "int": "1"  }
                         ]
                      },
                      {  "prim": "DIG",
                         "args": [
                           {  "int": "13"  }
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "14"  }
                         ]
                      },
                      {  "prim": "PAIR"  },
                      {  "prim": "EXEC"  },
                      {  "prim": "DIG",
                         "args": [
                           {  "int": "1"  }
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "2"  }
                         ]
                      },
                      {  "prim": "CDR",
                         "args": [
                           {  "int": "1"  }
                         ]
                      },
                      {  "prim": "DIG",
                         "args": [
                           {  "int": "4"  }
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "5"  }
                         ]
                      },
                      {  "prim": "ADD"  },
                      {  "prim": "DIP",
                         "args": [
                           {  "int": "1"  },
                           [  {  "prim": "DIG",
                                 "args": [
                                   {  "int": "3"  }
                                 ]
                           },
                           {  "prim": "DROP",
                              "args": [
                                {  "int": "1"  }
                              ]
                           }  ]
                         ]
                      },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "3"  }
                         ]
                      },
                      {  "prim": "PUSH",
                         "args": [
                           {  "prim": "nat"  },
                           {  "int": "0"  }
                         ]
                      },
                      {  "prim": "DIG",
                         "args": [
                           {  "int": "1"  }
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "2"  }
                         ]
                      },
                      {  "prim": "COMPARE"  },
                      {  "prim": "GT"  },
                      {  "prim": "IF",
                         "args": [
                           [  {  "prim": "DUP"  },
                           {  "prim": "DIG",
                              "args": [
                                {  "int": "3"  }
                              ]
                           },
                           {  "prim": "DUP"  },
                           {  "prim": "DUG",
                              "args": [
                                {  "int": "4"  }
                              ]
                           },
                           {  "prim": "SUB"  },
                           {  "prim": "DUP"  },
                           {  "prim": "PUSH",
                              "args": [
                                {  "prim": "int"  },
                                {  "int": "0"  }
                              ]
                           },
                           {  "prim": "COMPARE"  },
                           {  "prim": "GT"  },
                           {  "prim": "IF",
                              "args": [
                                [  {  "prim": "PUSH",
                                      "args": [
                                        {  "prim": "string"  },
                                        {  "string": "NegResult"  }
                                      ]
                                },
                                {  "prim": "FAILWITH"  }  ],
                                [    ]
                              ]
                           },
                           {  "prim": "ABS"  },
                           {  "prim": "DIP",
                              "args": [
                                {  "int": "1"  },
                                [  {  "prim": "DIG",
                                      "args": [
                                        {  "int": "2"  }
                                      ]
                                },
                                {  "prim": "DROP",
                                   "args": [
                                     {  "int": "1"  }
                                   ]
                                }  ]
                              ]
                           },
                           {  "prim": "DUG",
                              "args": [
                                {  "int": "2"  }
                              ]
                           },
                           {  "prim": "DIG",
                              "args": [
                                {  "int": "6"  }
                              ]
                           },
                           {  "prim": "DIG",
                              "args": [
                                {  "int": "9"  }
                              ]
                           },
                           {  "prim": "DUP"  },
                           {  "prim": "DUG",
                              "args": [
                                {  "int": "10"  }
                              ]
                           },
                           {  "prim": "DIG",
                              "args": [
                                {  "int": "3"  }
                              ]
                           },
                           {  "prim": "DUP"  },
                           {  "prim": "DUG",
                              "args": [
                                {  "int": "4"  }
                              ]
                           },
                           {  "prim": "CAR",
                              "args": [
                                {  "int": "0"  }
                              ]
                           },
                           {  "prim": "DIG",
                              "args": [
                                {  "int": "13"  }
                              ]
                           },
                           {  "prim": "DUP"  },
                           {  "prim": "DUG",
                              "args": [
                                {  "int": "14"  }
                              ]
                           },
                           {  "prim": "PAIR"  },
                           {  "prim": "DIG",
                              "args": [
                                {  "int": "3"  }
                              ]
                           },
                           {  "prim": "DUP"  },
                           {  "prim": "DUG",
                              "args": [
                                {  "int": "4"  }
                              ]
                           },
                           {  "prim": "DIG",
                              "args": [
                                {  "int": "16"  }
                              ]
                           },
                           {  "prim": "DUP"  },
                           {  "prim": "DUG",
                              "args": [
                                {  "int": "17"  }
                              ]
                           },
                           {  "prim": "PAIR"  },
                           {  "prim": "PAIR"  },
                           {  "prim": "EXEC"  },
                           {  "prim": "CONS"  },
                           {  "prim": "DUG",
                              "args": [
                                {  "int": "6"  }
                              ]
                           }  ],
                           [    ]
                         ]
                      },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "2"  }
                         ]
                      }  ]
                    ]
                 },
                 {  "prim": "NIL",
                    "args": [
                      {  "prim": "operation"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "5"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "6"  }
                    ]
                 },
                 {  "prim": "ITER",
                    "args": [
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "1"  }
                            ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "2"  }
                         ]
                      },
                      {  "prim": "DIG",
                         "args": [
                           {  "int": "1"  }
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "2"  }
                         ]
                      },
                      {  "prim": "CONS"  },
                      {  "prim": "DIP",
                         "args": [
                           {  "int": "1"  },
                           [  {  "prim": "DIG",
                                 "args": [
                                   {  "int": "1"  }
                                 ]
                           },
                           {  "prim": "DROP",
                              "args": [
                                {  "int": "1"  }
                              ]
                           }  ]
                         ]
                      },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "1"  }
                         ]
                      },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ]
                    ]
                 },
                 {  "prim": "DIP",
                    "args": [
                      {  "int": "1"  },
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "4"  }
                            ]
                      },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ]
                    ]
                 },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "4"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "CDR",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "ADD"  },
                 {  "prim": "DIP",
                    "args": [
                      {  "int": "1"  },
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "1"  }
                            ]
                      },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ]
                    ]
                 },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "PUSH",
                    "args": [
                      {  "prim": "nat"  },
                      {  "int": "10000"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "COMPARE"  },
                 {  "prim": "EQ"  },
                 {  "prim": "NOT"  },
                 {  "prim": "IF",
                    "args": [
                      [  {  "prim": "PUSH",
                            "args": [
                              {  "prim": "string"  },
                              {  "string": "Sum payouts Bps not equal 100%"  }
                            ]
                      },
                      {  "prim": "FAILWITH"  }  ],
                      [    ]
                    ]
                 },
                 {  "prim": "PUSH",
                    "args": [
                      {  "prim": "nat"  },
                      {  "int": "0"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "COMPARE"  },
                 {  "prim": "GT"  },
                 {  "prim": "IF",
                    "args": [
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "4"  }
                            ]
                      },
                      {  "prim": "DIG",
                         "args": [
                           {  "int": "7"  }
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "8"  }
                         ]
                      },
                      {  "prim": "DIG",
                         "args": [
                           {  "int": "4"  }
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "5"  }
                         ]
                      },
                      {  "prim": "CAR",
                         "args": [
                           {  "int": "0"  }
                         ]
                      },
                      {  "prim": "DIG",
                         "args": [
                           {  "int": "11"  }
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "12"  }
                         ]
                      },
                      {  "prim": "PAIR"  },
                      {  "prim": "DIG",
                         "args": [
                           {  "int": "3"  }
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "4"  }
                         ]
                      },
                      {  "prim": "DIG",
                         "args": [
                           {  "int": "14"  }
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "15"  }
                         ]
                      },
                      {  "prim": "PAIR"  },
                      {  "prim": "PAIR"  },
                      {  "prim": "EXEC"  },
                      {  "prim": "CONS"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "4"  }
                         ]
                      }  ],
                      [    ]
                    ]
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "4"  }
                    ]
                 }  ],
                 [    ]
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DIP",
               "args": [
                 {  "int": "1"  },
                 [  {  "prim": "DIG",
                       "args": [
                         {  "int": "1"  }
                       ]
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
                    ]
                 }  ]
               ]
            },
            {  "prim": "DUG",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DUG",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "6"  }
               ]
            }  ]
          ]
       },
       {  "prim": "LAMBDA",
          "args": [
            {  "prim": "pair",
               "args": [
                 {  "prim": "nat"  },
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "nat"  },
                      {  "prim": "pair",
                         "args": [
                           {  "prim": "list",
                              "args": [
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "address",
                                        "annots": [
                                          "%partAccount"
                                        ]
                                     },
                                     {  "prim": "nat",
                                        "annots": [
                                          "%partValue"
                                        ]
                                     }
                                   ]
                                }
                              ]
                           },
                           {  "prim": "lambda",
                              "args": [
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "nat"  },
                                     {  "prim": "nat"  }
                                   ]
                                },
                                {  "prim": "nat"  }
                              ]
                           }
                         ]
                      }
                    ]
                 }
               ]
            },
            {  "prim": "nat"  },
            [  {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "unit"  },
                 {  "prim": "Unit"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "7"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "EXEC"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "ADD"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "ITER",
               "args": [
                 [  {  "prim": "DIG",
                       "args": [
                         {  "int": "3"  }
                       ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "4"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "CDR",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "8"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "9"  }
                    ]
                 },
                 {  "prim": "PAIR"  },
                 {  "prim": "EXEC"  },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "ADD"  },
                 {  "prim": "DIP",
                    "args": [
                      {  "int": "1"  },
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "1"  }
                            ]
                      },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ]
                    ]
                 },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
                    ]
                 }  ]
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DIP",
               "args": [
                 {  "int": "1"  },
                 [  {  "prim": "DIG",
                       "args": [
                         {  "int": "1"  }
                       ]
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
                    ]
                 }  ]
               ]
            },
            {  "prim": "DUG",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DUG",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "4"  }
               ]
            }  ]
          ]
       },
       {  "prim": "LAMBDA",
          "args": [
            {  "prim": "pair",
               "args": [
                 {  "prim": "nat"  },
                 {  "prim": "nat"  }
               ]
            },
            {  "prim": "pair",
               "args": [
                 {  "prim": "nat"  },
                 {  "prim": "nat"  }
               ]
            },
            [  {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "unit"  },
                 {  "prim": "Unit"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "COMPARE"  },
            {  "prim": "GT"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "DIG",
                       "args": [
                         {  "int": "1"  }
                       ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "4"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "5"  }
                    ]
                 },
                 {  "prim": "SUB"  },
                 {  "prim": "DUP"  },
                 {  "prim": "PUSH",
                    "args": [
                      {  "prim": "int"  },
                      {  "int": "0"  }
                    ]
                 },
                 {  "prim": "COMPARE"  },
                 {  "prim": "GT"  },
                 {  "prim": "IF",
                    "args": [
                      [  {  "prim": "PUSH",
                            "args": [
                              {  "prim": "string"  },
                              {  "string": "NegResult"  }
                            ]
                      },
                      {  "prim": "FAILWITH"  }  ],
                      [    ]
                    ]
                 },
                 {  "prim": "ABS"  },
                 {  "prim": "PAIR"  }  ],
                 [  {  "prim": "DIG",
                       "args": [
                         {  "int": "2"  }
                       ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "PUSH",
                    "args": [
                      {  "prim": "nat"  },
                      {  "int": "0"  }
                    ]
                 },
                 {  "prim": "PAIR"  }  ]
               ]
            },
            {  "prim": "SWAP"  },
            {  "prim": "DROP",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DUG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "2"  }
               ]
            }  ]
          ]
       },
       {  "prim": "LAMBDA",
          "args": [
            {  "prim": "pair",
               "args": [
                 {  "prim": "nat"  },
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "nat"  },
                      {  "prim": "pair",
                         "args": [
                           {  "prim": "nat"  },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "lambda",
                                   "args": [
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "nat"  },
                                          {  "prim": "nat"  }
                                        ]
                                     },
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "nat"  },
                                          {  "prim": "nat"  }
                                        ]
                                     }
                                   ]
                                },
                                {  "prim": "lambda",
                                   "args": [
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "nat"  },
                                          {  "prim": "nat"  }
                                        ]
                                     },
                                     {  "prim": "nat"  }
                                   ]
                                }
                              ]
                           }
                         ]
                      }
                    ]
                 }
               ]
            },
            {  "prim": "pair",
               "args": [
                 {  "prim": "nat"  },
                 {  "prim": "nat"  }
               ]
            },
            [  {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "unit"  },
                 {  "prim": "Unit"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "7"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "8"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "EXEC"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "7"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "8"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "EXEC"  },
            {  "prim": "SWAP"  },
            {  "prim": "DROP",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DUG",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "5"  }
               ]
            }  ]
          ]
       },
       {  "prim": "LAMBDA",
          "args": [
            {  "prim": "pair",
               "args": [
                 {  "prim": "or",
                    "args": [
                      {  "prim": "unit"  },
                      {  "prim": "or",
                         "args": [
                           {  "prim": "unit"  },
                           {  "prim": "or",
                              "args": [
                                {  "prim": "unit"  },
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "unit"  },
                                     {  "prim": "bytes"  }
                                   ]
                                }
                              ]
                           }
                         ]
                      }
                    ]
                    ,
                    "annots": [
                      "%assetClass"
                    ]
                 },
                 {  "prim": "bytes",
                    "annots": [
                      "%assetData"
                    ]
                 }
               ]
            },
            {  "prim": "option",
               "args": [
                 {  "prim": "address"  }
               ]
            },
            [  {  "prim": "PUSH",
                  "args": [
                    {  "prim": "unit"  },
                    {  "prim": "Unit"  }
                  ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "CAR",
               "args": [
                 {  "int": "0"  }
               ]
            },
            {  "prim": "IF_LEFT",
               "args": [
                 [  {  "prim": "NONE",
                       "args": [
                         {  "prim": "address"  }
                       ]
                 },
                 {  "prim": "SWAP"  },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
                    ]
                 }  ],
                 [  {  "prim": "DUP"  },
                 {  "prim": "IF_LEFT",
                    "args": [
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "3"  }
                            ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "4"  }
                         ]
                      },
                      {  "prim": "CDR",
                         "args": [
                           {  "int": "1"  }
                         ]
                      },
                      {  "prim": "UNPACK",
                         "args": [
                           {  "prim": "address"  }
                         ]
                      },
                      {  "prim": "SWAP"  },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ],
                      [  {  "prim": "DUP"  },
                      {  "prim": "IF_LEFT",
                         "args": [
                           [  {  "prim": "DIG",
                                 "args": [
                                   {  "int": "4"  }
                                 ]
                           },
                           {  "prim": "DUP"  },
                           {  "prim": "DUG",
                              "args": [
                                {  "int": "5"  }
                              ]
                           },
                           {  "prim": "CDR",
                              "args": [
                                {  "int": "1"  }
                              ]
                           },
                           {  "prim": "UNPACK",
                              "args": [
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "address"  },
                                     {  "prim": "nat"  }
                                   ]
                                }
                              ]
                           },
                           {  "prim": "IF_NONE",
                              "args": [
                                [  {  "prim": "NONE",
                                      "args": [
                                        {  "prim": "address"  }
                                      ]
                                }  ],
                                [  {  "prim": "DUP"  },
                                {  "prim": "CAR",
                                   "args": [
                                     {  "int": "0"  }
                                   ]
                                },
                                {  "prim": "SOME"  },
                                {  "prim": "SWAP"  },
                                {  "prim": "DROP",
                                   "args": [
                                     {  "int": "1"  }
                                   ]
                                }  ]
                              ]
                           },
                           {  "prim": "SWAP"  },
                           {  "prim": "DROP",
                              "args": [
                                {  "int": "1"  }
                              ]
                           }  ],
                           [  {  "prim": "DUP"  },
                           {  "prim": "IF_LEFT",
                              "args": [
                                [  {  "prim": "NONE",
                                      "args": [
                                        {  "prim": "address"  }
                                      ]
                                },
                                {  "prim": "SWAP"  },
                                {  "prim": "DROP",
                                   "args": [
                                     {  "int": "1"  }
                                   ]
                                }  ],
                                [  {  "prim": "NONE",
                                      "args": [
                                        {  "prim": "address"  }
                                      ]
                                },
                                {  "prim": "SWAP"  },
                                {  "prim": "DROP",
                                   "args": [
                                     {  "int": "1"  }
                                   ]
                                }  ]
                              ]
                           },
                           {  "prim": "SWAP"  },
                           {  "prim": "DROP",
                              "args": [
                                {  "int": "1"  }
                              ]
                           }  ]
                         ]
                      },
                      {  "prim": "SWAP"  },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ]
                    ]
                 },
                 {  "prim": "SWAP"  },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
                    ]
                 }  ]
               ]
            },
            {  "prim": "SWAP"  },
            {  "prim": "DROP",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DUG",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "1"  }
               ]
            }  ]
          ]
       },
       {  "prim": "LAMBDA",
          "args": [
            {  "prim": "pair",
               "args": [
                 {  "prim": "address"  },
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "map",
                         "args": [
                           {  "prim": "address"  },
                           {  "prim": "address"  }
                         ]
                      },
                      {  "prim": "pair",
                         "args": [
                           {  "prim": "nat"  },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "nat"  },
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "nat"  },
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "address"  },
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "unit"  },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "unit"  },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                 ]
                                                              }
                                                            ]
                                                         }
                                                       ]
                                                       ,
                                                       "annots": [
                                                         "%assetClass"
                                                       ]
                                                    },
                                                    {  "prim": "bytes",
                                                       "annots": [
                                                         "%assetData"
                                                       ]
                                                    }
                                                  ]
                                               },
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "lambda",
                                                       "args": [
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "pair",
                                                                 "args": [
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetClass"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%assetData"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetType"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%assetValue"
                                                                   ]
                                                                   }
                                                                 ]
                                                              },
                                                              {  "prim": "pair",
                                                                 "args": [
                                                                   {  "prim": "address"  },
                                                                   {  "prim": "address"  }
                                                                 ]
                                                              }
                                                            ]
                                                         },
                                                         {  "prim": "operation"  }
                                                       ]
                                                    },
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "lambda",
                                                            "args": [
                                                              {  "prim": "pair",
                                                                 "args": [
                                                                   {  "prim": "address"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "map",
                                                                   "args": [

                                                                   {  "prim": "address"  },
                                                                   {  "prim": "address"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "option",
                                                                   "args": [

                                                                   {  "prim": "address"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                 ]
                                                              },
                                                              {  "prim": "address"  }
                                                            ]
                                                         },
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "lambda",
                                                                 "args": [
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetClass"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%assetData"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "option",
                                                                   "args": [

                                                                   {  "prim": "address"  }
                                                                   ]
                                                                   }
                                                                 ]
                                                              },
                                                              {  "prim": "pair",
                                                                 "args": [
                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                 ]
                                                              }
                                                            ]
                                                         }
                                                       ]
                                                    }
                                                  ]
                                               }
                                             ]
                                          }
                                        ]
                                     }
                                   ]
                                }
                              ]
                           }
                         ]
                      }
                    ]
                 }
               ]
            },
            {  "prim": "pair",
               "args": [
                 {  "prim": "nat"  },
                 {  "prim": "list",
                    "args": [
                      {  "prim": "operation"  }
                    ]
                 }
               ]
            },
            [  {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "unit"  },
                 {  "prim": "Unit"  }
               ]
            },
            {  "prim": "NIL",
               "args": [
                 {  "prim": "operation"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "nat"  },
                 {  "int": "2"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "15"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "16"  }
               ]
            },
            {  "prim": "MUL"  },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "12"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "13"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "13"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "14"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "EXEC"  },
            {  "prim": "DUP"  },
            {  "prim": "CDR",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "nat"  },
                 {  "int": "0"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "COMPARE"  },
            {  "prim": "GT"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "DIG",
                       "args": [
                         {  "int": "7"  }
                       ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "8"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "11"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "12"  }
                    ]
                 },
                 {  "prim": "EXEC"  },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "10"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "11"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "10"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "11"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "4"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "19"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "20"  }
                    ]
                 },
                 {  "prim": "PAIR"  },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "20"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "21"  }
                    ]
                 },
                 {  "prim": "PAIR"  },
                 {  "prim": "EXEC"  },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "14"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "15"  }
                    ]
                 },
                 {  "prim": "PAIR"  },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "4"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "5"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "14"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "15"  }
                    ]
                 },
                 {  "prim": "PAIR"  },
                 {  "prim": "PAIR"  },
                 {  "prim": "EXEC"  },
                 {  "prim": "CONS"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
                    ]
                 }  ],
                 [    ]
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "CAR",
               "args": [
                 {  "int": "0"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIP",
               "args": [
                 {  "int": "1"  },
                 [  {  "prim": "DIG",
                       "args": [
                         {  "int": "3"  }
                       ]
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
                    ]
                 }  ]
               ]
            },
            {  "prim": "DUG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DUG",
               "args": [
                 {  "int": "13"  }
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "13"  }
               ]
            }  ]
          ]
       },
       {  "prim": "LAMBDA",
          "args": [
            {  "prim": "pair",
               "args": [
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "or",
                         "args": [
                           {  "prim": "unit"  },
                           {  "prim": "or",
                              "args": [
                                {  "prim": "unit"  },
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "unit"  },
                                     {  "prim": "or",
                                        "args": [
                                          {  "prim": "unit"  },
                                          {  "prim": "bytes"  }
                                        ]
                                     }
                                   ]
                                }
                              ]
                           }
                         ]
                         ,
                         "annots": [
                           "%assetClass"
                         ]
                      },
                      {  "prim": "bytes",
                         "annots": [
                           "%assetData"
                         ]
                      }
                    ]
                 },
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "nat"  },
                      {  "prim": "pair",
                         "args": [
                           {  "prim": "nat"  },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "list",
                                   "args": [
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "address",
                                             "annots": [
                                               "%partAccount"
                                             ]
                                          },
                                          {  "prim": "nat",
                                             "annots": [
                                               "%partValue"
                                             ]
                                          }
                                        ]
                                     }
                                   ]
                                },
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "address"  },
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "lambda",
                                             "args": [
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                 ]
                                                                 ,
                                                                 "annots": [
                                                                   "%assetClass"
                                                                 ]
                                                              },
                                                              {  "prim": "bytes",
                                                                 "annots": [
                                                                   "%assetData"
                                                                 ]
                                                              }
                                                            ]
                                                            ,
                                                            "annots": [
                                                              "%assetType"
                                                            ]
                                                         },
                                                         {  "prim": "nat",
                                                            "annots": [
                                                              "%assetValue"
                                                            ]
                                                         }
                                                       ]
                                                    },
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "address"  },
                                                         {  "prim": "address"  }
                                                       ]
                                                    }
                                                  ]
                                               },
                                               {  "prim": "operation"  }
                                             ]
                                          },
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "lambda",
                                                  "args": [
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "nat"  },
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "nat"  },
                                                              {  "prim": "pair",
                                                                 "args": [
                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                 ]
                                                              }
                                                            ]
                                                         }
                                                       ]
                                                    },
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "nat"  },
                                                         {  "prim": "nat"  }
                                                       ]
                                                    }
                                                  ]
                                               },
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "lambda",
                                                       "args": [
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "nat"  },
                                                              {  "prim": "nat"  }
                                                            ]
                                                         },
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "nat"  },
                                                              {  "prim": "nat"  }
                                                            ]
                                                         }
                                                       ]
                                                    },
                                                    {  "prim": "lambda",
                                                       "args": [
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "nat"  },
                                                              {  "prim": "nat"  }
                                                            ]
                                                         },
                                                         {  "prim": "nat"  }
                                                       ]
                                                    }
                                                  ]
                                               }
                                             ]
                                          }
                                        ]
                                     }
                                   ]
                                }
                              ]
                           }
                         ]
                      }
                    ]
                 }
               ]
            },
            {  "prim": "pair",
               "args": [
                 {  "prim": "nat"  },
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "nat"  },
                      {  "prim": "list",
                         "args": [
                           {  "prim": "operation"  }
                         ]
                      }
                    ]
                 }
               ]
            },
            [  {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "unit"  },
                 {  "prim": "Unit"  }
               ]
            },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "nat"  },
                 {  "int": "0"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "9"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "10"  }
               ]
            },
            {  "prim": "NIL",
               "args": [
                 {  "prim": "operation"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "9"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "10"  }
               ]
            },
            {  "prim": "ITER",
               "args": [
                 [  {  "prim": "DUP"  },
                 {  "prim": "CDR",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "4"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "5"  }
                    ]
                 },
                 {  "prim": "ADD"  },
                 {  "prim": "DIP",
                    "args": [
                      {  "int": "1"  },
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "3"  }
                            ]
                      },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ]
                    ]
                 },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "7"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "8"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "6"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "7"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "8"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "9"  }
                    ]
                 },
                 {  "prim": "PAIR"  },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "CDR",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "PAIR"  },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "13"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "14"  }
                    ]
                 },
                 {  "prim": "PAIR"  },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "4"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "5"  }
                    ]
                 },
                 {  "prim": "PAIR"  },
                 {  "prim": "EXEC"  },
                 {  "prim": "DUP"  },
                 {  "prim": "CAR",
                    "args": [
                      {  "int": "0"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "CDR",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "DIP",
                    "args": [
                      {  "int": "1"  },
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "5"  }
                            ]
                      },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ]
                    ]
                 },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "5"  }
                    ]
                 },
                 {  "prim": "PUSH",
                    "args": [
                      {  "prim": "nat"  },
                      {  "int": "0"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "COMPARE"  },
                 {  "prim": "GT"  },
                 {  "prim": "IF",
                    "args": [
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "4"  }
                            ]
                      },
                      {  "prim": "DIG",
                         "args": [
                           {  "int": "11"  }
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "12"  }
                         ]
                      },
                      {  "prim": "DIG",
                         "args": [
                           {  "int": "5"  }
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "6"  }
                         ]
                      },
                      {  "prim": "CAR",
                         "args": [
                           {  "int": "0"  }
                         ]
                      },
                      {  "prim": "DIG",
                         "args": [
                           {  "int": "14"  }
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "15"  }
                         ]
                      },
                      {  "prim": "PAIR"  },
                      {  "prim": "DIG",
                         "args": [
                           {  "int": "3"  }
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "4"  }
                         ]
                      },
                      {  "prim": "DIG",
                         "args": [
                           {  "int": "19"  }
                         ]
                      },
                      {  "prim": "DUP"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "20"  }
                         ]
                      },
                      {  "prim": "PAIR"  },
                      {  "prim": "PAIR"  },
                      {  "prim": "EXEC"  },
                      {  "prim": "CONS"  },
                      {  "prim": "DUG",
                         "args": [
                           {  "int": "4"  }
                         ]
                      }  ],
                      [    ]
                    ]
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "4"  }
                    ]
                 }  ]
               ]
            },
            {  "prim": "NIL",
               "args": [
                 {  "prim": "operation"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "ITER",
               "args": [
                 [  {  "prim": "DIG",
                       "args": [
                         {  "int": "1"  }
                       ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "CONS"  },
                 {  "prim": "DIP",
                    "args": [
                      {  "int": "1"  },
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "1"  }
                            ]
                      },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ]
                    ]
                 },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
                    ]
                 }  ]
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIP",
               "args": [
                 {  "int": "1"  },
                 [  {  "prim": "DIG",
                       "args": [
                         {  "int": "3"  }
                       ]
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
                    ]
                 }  ]
               ]
            },
            {  "prim": "DUG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DUG",
               "args": [
                 {  "int": "9"  }
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "9"  }
               ]
            }  ]
          ]
       },
       {  "prim": "LAMBDA",
          "args": [
            {  "prim": "pair",
               "args": [
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "or",
                         "args": [
                           {  "prim": "unit"  },
                           {  "prim": "or",
                              "args": [
                                {  "prim": "unit"  },
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "unit"  },
                                     {  "prim": "or",
                                        "args": [
                                          {  "prim": "unit"  },
                                          {  "prim": "bytes"  }
                                        ]
                                     }
                                   ]
                                }
                              ]
                           }
                         ]
                         ,
                         "annots": [
                           "%assetClass"
                         ]
                      },
                      {  "prim": "bytes",
                         "annots": [
                           "%assetData"
                         ]
                      }
                    ]
                 },
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "pair",
                         "args": [
                           {  "prim": "or",
                              "args": [
                                {  "prim": "unit"  },
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "unit"  },
                                     {  "prim": "or",
                                        "args": [
                                          {  "prim": "unit"  },
                                          {  "prim": "or",
                                             "args": [
                                               {  "prim": "unit"  },
                                               {  "prim": "bytes"  }
                                             ]
                                          }
                                        ]
                                     }
                                   ]
                                }
                              ]
                              ,
                              "annots": [
                                "%assetClass"
                              ]
                           },
                           {  "prim": "bytes",
                              "annots": [
                                "%assetData"
                              ]
                           }
                         ]
                      },
                      {  "prim": "pair",
                         "args": [
                           {  "prim": "nat"  },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "nat"  },
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "address"  },
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "list",
                                             "args": [
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "address",
                                                       "annots": [
                                                         "%partAccount"
                                                       ]
                                                    },
                                                    {  "prim": "nat",
                                                       "annots": [
                                                         "%partValue"
                                                       ]
                                                    }
                                                  ]
                                               }
                                             ]
                                          },
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "lambda",
                                                  "args": [
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                 ]
                                                                 ,
                                                                 "annots": [
                                                                   "%assetClass"
                                                                 ]
                                                              },
                                                              {  "prim": "bytes",
                                                                 "annots": [
                                                                   "%assetData"
                                                                 ]
                                                              }
                                                            ]
                                                         },
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "nat"  },
                                                              {  "prim": "pair",
                                                                 "args": [
                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "list",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "address",
                                                                   "annots": [

                                                                   "%partAccount"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%partValue"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "address"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetClass"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%assetData"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetType"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%assetValue"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "address"  },
                                                                   {  "prim": "address"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {  "prim": "operation"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                 ]
                                                              }
                                                            ]
                                                         }
                                                       ]
                                                    },
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "nat"  },
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "nat"  },
                                                              {  "prim": "list",
                                                                 "args": [
                                                                   {  "prim": "operation"  }
                                                                 ]
                                                              }
                                                            ]
                                                         }
                                                       ]
                                                    }
                                                  ]
                                               },
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "lambda",
                                                       "args": [
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "pair",
                                                                 "args": [
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetClass"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%assetData"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetType"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%assetValue"
                                                                   ]
                                                                   }
                                                                 ]
                                                              },
                                                              {  "prim": "pair",
                                                                 "args": [
                                                                   {  "prim": "address"  },
                                                                   {  "prim": "address"  }
                                                                 ]
                                                              }
                                                            ]
                                                         },
                                                         {  "prim": "operation"  }
                                                       ]
                                                    },
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "lambda",
                                                            "args": [
                                                              {  "prim": "pair",
                                                                 "args": [
                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                 ]
                                                              },
                                                              {  "prim": "pair",
                                                                 "args": [
                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                 ]
                                                              }
                                                            ]
                                                         },
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "lambda",
                                                                 "args": [
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                 ]
                                                              },
                                                              {  "prim": "lambda",
                                                                 "args": [
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {  "prim": "nat"  }
                                                                 ]
                                                              }
                                                            ]
                                                         }
                                                       ]
                                                    }
                                                  ]
                                               }
                                             ]
                                          }
                                        ]
                                     }
                                   ]
                                }
                              ]
                           }
                         ]
                      }
                    ]
                 }
               ]
            },
            {  "prim": "pair",
               "args": [
                 {  "prim": "nat"  },
                 {  "prim": "list",
                    "args": [
                      {  "prim": "operation"  }
                    ]
                 }
               ]
            },
            [  {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "unit"  },
                 {  "prim": "Unit"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "7"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "9"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "10"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "8"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "9"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "10"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "11"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "11"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "12"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "13"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "14"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "EXEC"  },
            {  "prim": "DUP"  },
            {  "prim": "CAR",
               "args": [
                 {  "int": "0"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "CAR",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "CDR",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "nat"  },
                 {  "int": "5000"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "COMPARE"  },
            {  "prim": "LE"  },
            {  "prim": "NOT"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "PUSH",
                       "args": [
                         {  "prim": "string"  },
                         {  "string": "Royalties are too high (>50%)"  }
                       ]
                 },
                 {  "prim": "FAILWITH"  }  ],
                 [    ]
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIP",
               "args": [
                 {  "int": "1"  },
                 [  {  "prim": "DIG",
                       "args": [
                         {  "int": "4"  }
                       ]
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
                    ]
                 }  ]
               ]
            },
            {  "prim": "DUG",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "DUG",
               "args": [
                 {  "int": "11"  }
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "11"  }
               ]
            }  ]
          ]
       },
       {  "prim": "LAMBDA",
          "args": [
            {  "prim": "pair",
               "args": [
                 {  "prim": "address"  },
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "map",
                         "args": [
                           {  "prim": "address"  },
                           {  "prim": "address"  }
                         ]
                      },
                      {  "prim": "pair",
                         "args": [
                           {  "prim": "nat"  },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "nat"  },
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "address"  },
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "list",
                                                  "args": [
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "address",
                                                            "annots": [
                                                              "%partAccount"
                                                            ]
                                                         },
                                                         {  "prim": "nat",
                                                            "annots": [
                                                              "%partValue"
                                                            ]
                                                         }
                                                       ]
                                                    }
                                                  ]
                                                  ,
                                                  "annots": [
                                                    "%payouts"
                                                  ]
                                               },
                                               {  "prim": "list",
                                                  "args": [
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "address",
                                                            "annots": [
                                                              "%partAccount"
                                                            ]
                                                         },
                                                         {  "prim": "nat",
                                                            "annots": [
                                                              "%partValue"
                                                            ]
                                                         }
                                                       ]
                                                    }
                                                  ]
                                                  ,
                                                  "annots": [
                                                    "%originFees"
                                                  ]
                                               }
                                             ]
                                          },
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "list",
                                                       "args": [
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "address",
                                                                 "annots": [
                                                                   "%partAccount"
                                                                 ]
                                                              },
                                                              {  "prim": "nat",
                                                                 "annots": [
                                                                   "%partValue"
                                                                 ]
                                                              }
                                                            ]
                                                         }
                                                       ]
                                                       ,
                                                       "annots": [
                                                         "%payouts"
                                                       ]
                                                    },
                                                    {  "prim": "list",
                                                       "args": [
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "address",
                                                                 "annots": [
                                                                   "%partAccount"
                                                                 ]
                                                              },
                                                              {  "prim": "nat",
                                                                 "annots": [
                                                                   "%partValue"
                                                                 ]
                                                              }
                                                            ]
                                                         }
                                                       ]
                                                       ,
                                                       "annots": [
                                                         "%originFees"
                                                       ]
                                                    }
                                                  ]
                                               },
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "unit"  },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                 ]
                                                              }
                                                            ]
                                                            ,
                                                            "annots": [
                                                              "%assetClass"
                                                            ]
                                                         },
                                                         {  "prim": "bytes",
                                                            "annots": [
                                                              "%assetData"
                                                            ]
                                                         }
                                                       ]
                                                    },
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                 ]
                                                                 ,
                                                                 "annots": [
                                                                   "%assetClass"
                                                                 ]
                                                              },
                                                              {  "prim": "bytes",
                                                                 "annots": [
                                                                   "%assetData"
                                                                 ]
                                                              }
                                                            ]
                                                         },
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "list",
                                                                 "args": [
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "address",
                                                                   "annots": [

                                                                   "%partAccount"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%partValue"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                 ]
                                                              },
                                                              {  "prim": "pair",
                                                                 "args": [
                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetClass"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%assetData"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "address"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "list",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "address",
                                                                   "annots": [

                                                                   "%partAccount"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%partValue"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetClass"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%assetData"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetType"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%assetValue"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "address"  },
                                                                   {  "prim": "address"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {  "prim": "operation"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "list",
                                                                   "args": [

                                                                   {  "prim": "operation"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetClass"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%assetData"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetClass"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%assetData"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "address"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "list",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "address",
                                                                   "annots": [

                                                                   "%partAccount"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%partValue"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetClass"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%assetData"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "list",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "address",
                                                                   "annots": [

                                                                   "%partAccount"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%partValue"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "address"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetClass"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%assetData"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetType"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%assetValue"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "address"  },
                                                                   {  "prim": "address"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {  "prim": "operation"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "list",
                                                                   "args": [

                                                                   {  "prim": "operation"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetClass"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%assetData"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetType"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%assetValue"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "address"  },
                                                                   {  "prim": "address"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {  "prim": "operation"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "list",
                                                                   "args": [

                                                                   {  "prim": "operation"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetClass"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%assetData"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "list",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "address",
                                                                   "annots": [

                                                                   "%partAccount"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%partValue"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "address"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetClass"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%assetData"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetType"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%assetValue"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "address"  },
                                                                   {  "prim": "address"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {  "prim": "operation"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "list",
                                                                   "args": [

                                                                   {  "prim": "operation"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "address"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "map",
                                                                   "args": [

                                                                   {  "prim": "address"  },
                                                                   {  "prim": "address"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "address"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetClass"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%assetData"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetClass"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%assetData"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetType"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%assetValue"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "address"  },
                                                                   {  "prim": "address"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {  "prim": "operation"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "address"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "map",
                                                                   "args": [

                                                                   {  "prim": "address"  },
                                                                   {  "prim": "address"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "option",
                                                                   "args": [

                                                                   {  "prim": "address"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {  "prim": "address"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetClass"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%assetData"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "option",
                                                                   "args": [

                                                                   {  "prim": "address"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "list",
                                                                   "args": [

                                                                   {  "prim": "operation"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetClass"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%assetData"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetType"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%assetValue"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "address"  },
                                                                   {  "prim": "address"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {  "prim": "operation"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "address"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "map",
                                                                   "args": [

                                                                   {  "prim": "address"  },
                                                                   {  "prim": "address"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "option",
                                                                   "args": [

                                                                   {  "prim": "address"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {  "prim": "address"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {  "prim": "unit"  },
                                                                   {  "prim": "bytes"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%assetClass"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [

                                                                   "%assetData"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "option",
                                                                   "args": [

                                                                   {  "prim": "address"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "list",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "address",
                                                                   "annots": [

                                                                   "%partAccount"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%partValue"
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "lambda",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   }
                                                                 ]
                                                              }
                                                            ]
                                                         }
                                                       ]
                                                    }
                                                  ]
                                               }
                                             ]
                                          }
                                        ]
                                     }
                                   ]
                                }
                              ]
                           }
                         ]
                      }
                    ]
                 }
               ]
            },
            {  "prim": "pair",
               "args": [
                 {  "prim": "nat"  },
                 {  "prim": "list",
                    "args": [
                      {  "prim": "operation"  }
                    ]
                 }
               ]
            },
            [  {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "unit"  },
                 {  "prim": "Unit"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "18"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "19"  }
               ]
            },
            {  "prim": "CDR",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "21"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "22"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "20"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "21"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "EXEC"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "9"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "10"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "7"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "7"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "8"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "8"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "9"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "9"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "10"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "10"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "11"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "17"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "18"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "20"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "21"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "21"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "22"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "22"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "23"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "23"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "24"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "24"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "25"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "EXEC"  },
            {  "prim": "DUP"  },
            {  "prim": "CDR",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "13"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "14"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "8"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "9"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "9"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "10"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "12"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "13"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "14"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "15"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "17"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "18"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "22"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "23"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "23"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "24"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "CAR",
               "args": [
                 {  "int": "0"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "18"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "19"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "19"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "20"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "EXEC"  },
            {  "prim": "DUP"  },
            {  "prim": "CDR",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "14"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "15"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "7"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "8"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "10"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "11"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "11"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "12"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "14"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "15"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "24"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "25"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "23"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "24"  }
               ]
            },
            {  "prim": "CDR",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "25"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "26"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "CAR",
               "args": [
                 {  "int": "0"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "21"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "22"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "EXEC"  },
            {  "prim": "DUP"  },
            {  "prim": "CDR",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "16"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "17"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "9"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "10"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "12"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "13"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "13"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "14"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "16"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "17"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "26"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "27"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "24"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "25"  }
               ]
            },
            {  "prim": "CDR",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "27"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "28"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "CAR",
               "args": [
                 {  "int": "0"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "23"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "24"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "EXEC"  },
            {  "prim": "DUP"  },
            {  "prim": "CDR",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "20"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "21"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "11"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "12"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "18"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "19"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "26"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "27"  }
               ]
            },
            {  "prim": "CAR",
               "args": [
                 {  "int": "0"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "28"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "29"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "CAR",
               "args": [
                 {  "int": "0"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "25"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "26"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "EXEC"  },
            {  "prim": "DUP"  },
            {  "prim": "NIL",
               "args": [
                 {  "prim": "operation"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "ITER",
               "args": [
                 [  {  "prim": "DIG",
                       "args": [
                         {  "int": "1"  }
                       ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "CONS"  },
                 {  "prim": "DIP",
                    "args": [
                      {  "int": "1"  },
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "1"  }
                            ]
                      },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ]
                    ]
                 },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
                    ]
                 }  ]
               ]
            },
            {  "prim": "ITER",
               "args": [
                 [  {  "prim": "DIG",
                       "args": [
                         {  "int": "1"  }
                       ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "CONS"  },
                 {  "prim": "DIP",
                    "args": [
                      {  "int": "1"  },
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "1"  }
                            ]
                      },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ]
                    ]
                 },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
                    ]
                 }  ]
               ]
            },
            {  "prim": "NIL",
               "args": [
                 {  "prim": "operation"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "ITER",
               "args": [
                 [  {  "prim": "DIG",
                       "args": [
                         {  "int": "1"  }
                       ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "CONS"  },
                 {  "prim": "DIP",
                    "args": [
                      {  "int": "1"  },
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "1"  }
                            ]
                      },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ]
                    ]
                 },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
                    ]
                 }  ]
               ]
            },
            {  "prim": "ITER",
               "args": [
                 [  {  "prim": "DIG",
                       "args": [
                         {  "int": "1"  }
                       ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "CONS"  },
                 {  "prim": "DIP",
                    "args": [
                      {  "int": "1"  },
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "1"  }
                            ]
                      },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ]
                    ]
                 },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
                    ]
                 }  ]
               ]
            },
            {  "prim": "NIL",
               "args": [
                 {  "prim": "operation"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "7"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "8"  }
               ]
            },
            {  "prim": "ITER",
               "args": [
                 [  {  "prim": "DIG",
                       "args": [
                         {  "int": "1"  }
                       ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "CONS"  },
                 {  "prim": "DIP",
                    "args": [
                      {  "int": "1"  },
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "1"  }
                            ]
                      },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ]
                    ]
                 },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
                    ]
                 }  ]
               ]
            },
            {  "prim": "ITER",
               "args": [
                 [  {  "prim": "DIG",
                       "args": [
                         {  "int": "1"  }
                       ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "CONS"  },
                 {  "prim": "DIP",
                    "args": [
                      {  "int": "1"  },
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "1"  }
                            ]
                      },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ]
                    ]
                 },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
                    ]
                 }  ]
               ]
            },
            {  "prim": "NIL",
               "args": [
                 {  "prim": "operation"  }
               ]
            },
            {  "prim": "DIG",
               "args": [
                 {  "int": "9"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "10"  }
               ]
            },
            {  "prim": "ITER",
               "args": [
                 [  {  "prim": "DIG",
                       "args": [
                         {  "int": "1"  }
                       ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "CONS"  },
                 {  "prim": "DIP",
                    "args": [
                      {  "int": "1"  },
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "1"  }
                            ]
                      },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ]
                    ]
                 },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
                    ]
                 }  ]
               ]
            },
            {  "prim": "ITER",
               "args": [
                 [  {  "prim": "DIG",
                       "args": [
                         {  "int": "1"  }
                       ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "DIG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "CONS"  },
                 {  "prim": "DIP",
                    "args": [
                      {  "int": "1"  },
                      [  {  "prim": "DIG",
                            "args": [
                              {  "int": "1"  }
                            ]
                      },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ]
                    ]
                 },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
                    ]
                 }  ]
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DIG",
               "args": [
                 {  "int": "11"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "12"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DIP",
               "args": [
                 {  "int": "1"  },
                 [  {  "prim": "DIG",
                       "args": [
                         {  "int": "11"  }
                       ]
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
                    ]
                 }  ]
               ]
            },
            {  "prim": "DUG",
               "args": [
                 {  "int": "11"  }
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "11"  }
               ]
            },
            {  "prim": "DUG",
               "args": [
                 {  "int": "21"  }
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "21"  }
               ]
            }  ]
          ]
       },
       {  "prim": "NIL",
          "args": [
            {  "prim": "operation"  }
          ]
       },
       {  "prim": "DIG",
          "args": [
            {  "int": "15"  }
          ]
       },
       {  "prim": "UNPAIR"  },
       {  "prim": "DIP",
          "args": [
            {  "int": "1"  },
            [  {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  }  ]
          ]
       },
       {  "prim": "IF_LEFT",
          "args": [
            [  {  "prim": "IF_LEFT",
                  "args": [
                    [  {  "prim": "IF_LEFT",
                          "args": [
                            [  {  "prim": "IF_LEFT",
                                  "args": [
                                    [  {  "prim": "DIG",
                                          "args": [
                                            {  "int": "7"  }
                                          ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "8"  }
                                       ]
                                    },
                                    {  "prim": "SENDER"  },
                                    {  "prim": "COMPARE"  },
                                    {  "prim": "EQ"  },
                                    {  "prim": "NOT"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "InvalidCaller"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "SOME"  },
                                    {  "prim": "DIP",
                                       "args": [
                                         {  "int": "1"  },
                                         [  {  "prim": "DIG",
                                               "args": [
                                                 {  "int": "2"  }
                                               ]
                                         },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         }  ]
                                       ]
                                    },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "2"  }
                                       ]
                                    },
                                    {  "prim": "DROP",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "PAIR"  }  ],
                                    [  {  "prim": "DIG",
                                          "args": [
                                            {  "int": "7"  }
                                          ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "8"  }
                                       ]
                                    },
                                    {  "prim": "SENDER"  },
                                    {  "prim": "COMPARE"  },
                                    {  "prim": "EQ"  },
                                    {  "prim": "NOT"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "InvalidCaller"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "SOME"  },
                                    {  "prim": "DIP",
                                       "args": [
                                         {  "int": "1"  },
                                         [  {  "prim": "DIG",
                                               "args": [
                                                 {  "int": "4"  }
                                               ]
                                         },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         }  ]
                                       ]
                                    },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "4"  }
                                       ]
                                    },
                                    {  "prim": "DROP",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "PAIR"  }  ]
                                  ]
                            }  ],
                            [  {  "prim": "IF_LEFT",
                                  "args": [
                                    [  {  "prim": "DROP",
                                          "args": [
                                            {  "int": "1"  }
                                          ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "3"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "4"  }
                                       ]
                                    },
                                    {  "prim": "IF_NONE",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "NotFound"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "SENDER"  },
                                    {  "prim": "COMPARE"  },
                                    {  "prim": "EQ"  },
                                    {  "prim": "NOT"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "InvalidCaller"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "3"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "4"  }
                                       ]
                                    },
                                    {  "prim": "IF_NONE",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "NotFound"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DIP",
                                       "args": [
                                         {  "int": "1"  },
                                         [  {  "prim": "DIG",
                                               "args": [
                                                 {  "int": "6"  }
                                               ]
                                         },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         }  ]
                                       ]
                                    },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "6"  }
                                       ]
                                    },
                                    {  "prim": "NONE",
                                       "args": [
                                         {  "prim": "address"  }
                                       ]
                                    },
                                    {  "prim": "DIP",
                                       "args": [
                                         {  "int": "1"  },
                                         [  {  "prim": "DIG",
                                               "args": [
                                                 {  "int": "3"  }
                                               ]
                                         },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         }  ]
                                       ]
                                    },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "3"  }
                                       ]
                                    },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "PAIR"  }  ],
                                    [  {  "prim": "UNPAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "8"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "9"  }
                                       ]
                                    },
                                    {  "prim": "SENDER"  },
                                    {  "prim": "COMPARE"  },
                                    {  "prim": "EQ"  },
                                    {  "prim": "NOT"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "InvalidCaller"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "4"  }
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "2"  }
                                       ]
                                    },
                                    {  "prim": "SOME"  },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "3"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "4"  }
                                       ]
                                    },
                                    {  "prim": "UPDATE"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "4"  }
                                       ]
                                    },
                                    {  "prim": "DROP",
                                       "args": [
                                         {  "int": "2"  }
                                       ]
                                    },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "PAIR"  }  ]
                                  ]
                            }  ]
                          ]
                    }  ],
                    [  {  "prim": "IF_LEFT",
                          "args": [
                            [  {  "prim": "IF_LEFT",
                                  "args": [
                                    [  {  "prim": "DIG",
                                          "args": [
                                            {  "int": "7"  }
                                          ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "8"  }
                                       ]
                                    },
                                    {  "prim": "SENDER"  },
                                    {  "prim": "COMPARE"  },
                                    {  "prim": "EQ"  },
                                    {  "prim": "NOT"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "InvalidCaller"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DIP",
                                       "args": [
                                         {  "int": "1"  },
                                         [  {  "prim": "DIG",
                                               "args": [
                                                 {  "int": "6"  }
                                               ]
                                         },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         }  ]
                                       ]
                                    },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "6"  }
                                       ]
                                    },
                                    {  "prim": "DROP",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "PAIR"  }  ],
                                    [  {  "prim": "DIG",
                                          "args": [
                                            {  "int": "2"  }
                                          ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "3"  }
                                       ]
                                    },
                                    {  "prim": "IF_NONE",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "bool"  },
                                                 {  "prim": "False"  }
                                               ]
                                         }  ],
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "bool"  },
                                                 {  "prim": "True"  }
                                               ]
                                         },
                                         {  "prim": "SWAP"  },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         }  ]
                                       ]
                                    },
                                    {  "prim": "NOT"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "validator is unset"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "8"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "9"  }
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "3"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "4"  }
                                       ]
                                    },
                                    {  "prim": "IF_NONE",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "NotFound"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "CONTRACT",
                                       "args": [
                                         {  "prim": "pair",
                                            "args": [
                                              {  "prim": "option",
                                                 "args": [
                                                   {  "prim": "key"  }
                                                 ]
                                              },
                                              {  "prim": "pair",
                                                 "args": [
                                                   {  "prim": "pair",
                                                      "args": [
                                                        {  "prim": "pair",
                                                           "args": [
                                                             {  "prim": "or",
                                                                "args": [
                                                                  {  "prim": "unit"  },
                                                                  {
                                                                  "prim": "or",
                                                                  "args": [
                                                                    {  "prim": "unit"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "unit"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "unit"  },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                    }
                                                                    ]
                                                                    }
                                                                  ]
                                                                  }
                                                                ]
                                                             },
                                                             {  "prim": "bytes"  }
                                                           ]
                                                        },
                                                        {  "prim": "nat"  }
                                                      ]
                                                   },
                                                   {  "prim": "pair",
                                                      "args": [
                                                        {  "prim": "option",
                                                           "args": [
                                                             {  "prim": "key"  }
                                                           ]
                                                        },
                                                        {  "prim": "pair",
                                                           "args": [
                                                             {  "prim": "pair",
                                                                "args": [
                                                                  {
                                                                  "prim": "pair",
                                                                  "args": [
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "unit"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "unit"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "unit"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "unit"  },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                    }
                                                                    ]
                                                                    }
                                                                    ]
                                                                    }
                                                                    ]
                                                                    },
                                                                    {  "prim": "bytes"  }
                                                                  ]
                                                                  },
                                                                  {  "prim": "nat"  }
                                                                ]
                                                             },
                                                             {  "prim": "pair",
                                                                "args": [
                                                                  {  "prim": "nat"  },
                                                                  {
                                                                  "prim": "pair",
                                                                  "args": [
                                                                    {
                                                                    "prim": "option",
                                                                    "args": [

                                                                    {  "prim": "timestamp"  }
                                                                    ]
                                                                    },
                                                                    {
                                                                    "prim": "pair",
                                                                    "args": [

                                                                    {
                                                                    "prim": "option",
                                                                    "args": [

                                                                    {  "prim": "timestamp"  }
                                                                    ]
                                                                    },
                                                                    {
                                                                    "prim": "pair",
                                                                    "args": [

                                                                    {  "prim": "bytes"  },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                    }
                                                                    ]
                                                                    }
                                                                  ]
                                                                  }
                                                                ]
                                                             }
                                                           ]
                                                        }
                                                      ]
                                                   }
                                                 ]
                                              }
                                            ]
                                         }
                                       ]
                                       ,
                                       "annots": [
                                         "%cancel"
                                       ]
                                    },
                                    {  "prim": "IF_NONE",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "NotFound"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "AMOUNT"  },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "3"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "4"  }
                                       ]
                                    },
                                    {  "prim": "TRANSFER_TOKENS"  },
                                    {  "prim": "CONS"  },
                                    {  "prim": "DIP",
                                       "args": [
                                         {  "int": "1"  },
                                         [  {  "prim": "DIG",
                                               "args": [
                                                 {  "int": "8"  }
                                               ]
                                         },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         }  ]
                                       ]
                                    },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "8"  }
                                       ]
                                    },
                                    {  "prim": "DROP",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "PAIR"  }  ]
                                  ]
                            }  ],
                            [  {  "prim": "IF_LEFT",
                                  "args": [
                                    [  {  "prim": "DIG",
                                          "args": [
                                            {  "int": "7"  }
                                          ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "8"  }
                                       ]
                                    },
                                    {  "prim": "SENDER"  },
                                    {  "prim": "COMPARE"  },
                                    {  "prim": "EQ"  },
                                    {  "prim": "NOT"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "InvalidCaller"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "2"  }
                                       ]
                                    },
                                    {  "prim": "SOME"  },
                                    {  "prim": "PUSH",
                                       "args": [
                                         {  "prim": "string"  },
                                         {  "string": ""  }
                                       ]
                                    },
                                    {  "prim": "UPDATE"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "DROP",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "PAIR"  }  ],
                                    [  {  "prim": "DIG",
                                          "args": [
                                            {  "int": "7"  }
                                          ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "8"  }
                                       ]
                                    },
                                    {  "prim": "SENDER"  },
                                    {  "prim": "COMPARE"  },
                                    {  "prim": "EQ"  },
                                    {  "prim": "NOT"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "InvalidCaller"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "8"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "9"  }
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "3"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "4"  }
                                       ]
                                    },
                                    {  "prim": "IF_NONE",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "validator is unset"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "CONTRACT",
                                       "args": [
                                         {  "prim": "bytes"  }
                                       ]
                                       ,
                                       "annots": [
                                         "%setMetadataUri"
                                       ]
                                    },
                                    {  "prim": "IF_NONE",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "NotFound"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "AMOUNT"  },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "3"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "4"  }
                                       ]
                                    },
                                    {  "prim": "TRANSFER_TOKENS"  },
                                    {  "prim": "CONS"  },
                                    {  "prim": "DIP",
                                       "args": [
                                         {  "int": "1"  },
                                         [  {  "prim": "DIG",
                                               "args": [
                                                 {  "int": "8"  }
                                               ]
                                         },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         }  ]
                                       ]
                                    },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "8"  }
                                       ]
                                    },
                                    {  "prim": "DROP",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "PAIR"  }  ]
                                  ]
                            }  ]
                          ]
                    }  ]
                  ]
            }  ],
            [  {  "prim": "IF_LEFT",
                  "args": [
                    [  {  "prim": "IF_LEFT",
                          "args": [
                            [  {  "prim": "IF_LEFT",
                                  "args": [
                                    [  {  "prim": "DIG",
                                          "args": [
                                            {  "int": "7"  }
                                          ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "8"  }
                                       ]
                                    },
                                    {  "prim": "SENDER"  },
                                    {  "prim": "COMPARE"  },
                                    {  "prim": "EQ"  },
                                    {  "prim": "NOT"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "InvalidCaller"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DIP",
                                       "args": [
                                         {  "int": "1"  },
                                         [  {  "prim": "DIG",
                                               "args": [
                                                 {  "int": "5"  }
                                               ]
                                         },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         }  ]
                                       ]
                                    },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "5"  }
                                       ]
                                    },
                                    {  "prim": "DROP",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "PAIR"  }  ],
                                    [  {  "prim": "DIG",
                                          "args": [
                                            {  "int": "7"  }
                                          ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "8"  }
                                       ]
                                    },
                                    {  "prim": "SENDER"  },
                                    {  "prim": "COMPARE"  },
                                    {  "prim": "EQ"  },
                                    {  "prim": "NOT"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "InvalidCaller"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "8"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "9"  }
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "3"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "4"  }
                                       ]
                                    },
                                    {  "prim": "IF_NONE",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "NotFound"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "CONTRACT",
                                       "args": [
                                         {  "prim": "address"  }
                                       ]
                                       ,
                                       "annots": [
                                         "%setRoyaltiesContract"
                                       ]
                                    },
                                    {  "prim": "IF_NONE",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "NotFound"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "AMOUNT"  },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "3"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "4"  }
                                       ]
                                    },
                                    {  "prim": "TRANSFER_TOKENS"  },
                                    {  "prim": "CONS"  },
                                    {  "prim": "DIP",
                                       "args": [
                                         {  "int": "1"  },
                                         [  {  "prim": "DIG",
                                               "args": [
                                                 {  "int": "8"  }
                                               ]
                                         },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         }  ]
                                       ]
                                    },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "8"  }
                                       ]
                                    },
                                    {  "prim": "DROP",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "PAIR"  }  ]
                                  ]
                            }  ],
                            [  {  "prim": "IF_LEFT",
                                  "args": [
                                    [  {  "prim": "UNPAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "8"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "9"  }
                                       ]
                                    },
                                    {  "prim": "SENDER"  },
                                    {  "prim": "COMPARE"  },
                                    {  "prim": "EQ"  },
                                    {  "prim": "NOT"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "InvalidCaller"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "9"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "10"  }
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "4"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "5"  }
                                       ]
                                    },
                                    {  "prim": "IF_NONE",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "NotFound"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "CONTRACT",
                                       "args": [
                                         {  "prim": "pair",
                                            "args": [
                                              {  "prim": "or",
                                                 "args": [
                                                   {  "prim": "unit"  },
                                                   {  "prim": "or",
                                                      "args": [
                                                        {  "prim": "unit"  },
                                                        {  "prim": "or",
                                                           "args": [
                                                             {  "prim": "unit"  },
                                                             {  "prim": "or",
                                                                "args": [
                                                                  {  "prim": "unit"  },
                                                                  {  "prim": "bytes"  }
                                                                ]
                                                             }
                                                           ]
                                                        }
                                                      ]
                                                   }
                                                 ]
                                              },
                                              {  "prim": "address"  }
                                            ]
                                         }
                                       ]
                                       ,
                                       "annots": [
                                         "%setAssetMatcher"
                                       ]
                                    },
                                    {  "prim": "IF_NONE",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "NotFound"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "AMOUNT"  },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "3"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "4"  }
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "5"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "6"  }
                                       ]
                                    },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "TRANSFER_TOKENS"  },
                                    {  "prim": "CONS"  },
                                    {  "prim": "DIP",
                                       "args": [
                                         {  "int": "1"  },
                                         [  {  "prim": "DIG",
                                               "args": [
                                                 {  "int": "9"  }
                                               ]
                                         },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         }  ]
                                       ]
                                    },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "9"  }
                                       ]
                                    },
                                    {  "prim": "DROP",
                                       "args": [
                                         {  "int": "2"  }
                                       ]
                                    },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "PAIR"  }  ],
                                    [  {  "prim": "UNPAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "UNPAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "UNPAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "UNPAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "UNPAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "UNPAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "8"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "9"  }
                                       ]
                                    },
                                    {  "prim": "IF_NONE",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "validator is unset"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "SENDER"  },
                                    {  "prim": "COMPARE"  },
                                    {  "prim": "EQ"  },
                                    {  "prim": "NOT"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "InvalidCaller"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "4"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "5"  }
                                       ]
                                    },
                                    {  "prim": "CAR",
                                       "args": [
                                         {  "int": "0"  }
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "5"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "6"  }
                                       ]
                                    },
                                    {  "prim": "CDR",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "28"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "29"  }
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "30"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "31"  }
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "7"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "8"  }
                                       ]
                                    },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "PUSH",
                                       "args": [
                                         {  "prim": "string"  },
                                         {  "string": "V1"  }
                                       ]
                                    },
                                    {  "prim": "PACK"  },
                                    {  "prim": "KECCAK"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "EXEC"  },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "29"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "30"  }
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "31"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "32"  }
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "7"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "8"  }
                                       ]
                                    },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "PUSH",
                                       "args": [
                                         {  "prim": "string"  },
                                         {  "string": "V1"  }
                                       ]
                                    },
                                    {  "prim": "PACK"  },
                                    {  "prim": "KECCAK"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "EXEC"  },
                                    {  "prim": "NIL",
                                       "args": [
                                         {  "prim": "operation"  }
                                       ]
                                    },
                                    {  "prim": "NIL",
                                       "args": [
                                         {  "prim": "operation"  }
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "9"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "10"  }
                                       ]
                                    },
                                    {  "prim": "CAR",
                                       "args": [
                                         {  "int": "0"  }
                                       ]
                                    },
                                    {  "prim": "IF_NONE",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "NotFound"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "HASH_KEY"  },
                                    {  "prim": "IMPLICIT_ACCOUNT"  },
                                    {  "prim": "ADDRESS"  },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "9"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "10"  }
                                       ]
                                    },
                                    {  "prim": "CAR",
                                       "args": [
                                         {  "int": "0"  }
                                       ]
                                    },
                                    {  "prim": "IF_NONE",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "NotFound"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "HASH_KEY"  },
                                    {  "prim": "IMPLICIT_ACCOUNT"  },
                                    {  "prim": "ADDRESS"  },
                                    {  "prim": "PUSH",
                                       "args": [
                                         {  "prim": "nat"  },
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "10"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "11"  }
                                       ]
                                    },
                                    {  "prim": "COMPARE"  },
                                    {  "prim": "EQ"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "DIG",
                                               "args": [
                                                 {  "int": "23"  }
                                               ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "24"  }
                                            ]
                                         },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "34"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "35"  }
                                            ]
                                         },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "32"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "33"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "31"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "32"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "30"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "31"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "29"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "30"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "38"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "39"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "34"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "35"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "28"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "29"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "27"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "28"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "26"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "27"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "33"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "34"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "10"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "11"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "15"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "16"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "16"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "17"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "6"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "7"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "7"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "8"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "3"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "4"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "14"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "15"  }
                                            ]
                                         },
                                         {  "prim": "CAR",
                                            "args": [
                                              {  "int": "0"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "21"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "22"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "19"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "20"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "22"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "23"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "EXEC"  },
                                         {  "prim": "DUP"  },
                                         {  "prim": "CAR",
                                            "args": [
                                              {  "int": "0"  }
                                            ]
                                         },
                                         {  "prim": "DIP",
                                            "args": [
                                              {  "int": "1"  },
                                              [  {  "prim": "DIG",
                                                    "args": [
                                                      {  "int": "8"  }
                                                    ]
                                              },
                                              {  "prim": "DROP",
                                                 "args": [
                                                   {  "int": "1"  }
                                                 ]
                                              }  ]
                                            ]
                                         },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "8"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "CDR",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         },
                                         {  "prim": "DIP",
                                            "args": [
                                              {  "int": "1"  },
                                              [  {  "prim": "DIG",
                                                    "args": [
                                                      {  "int": "4"  }
                                                    ]
                                              },
                                              {  "prim": "DROP",
                                                 "args": [
                                                   {  "int": "1"  }
                                                 ]
                                              }  ]
                                            ]
                                         },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "4"  }
                                            ]
                                         },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "32"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "33"  }
                                            ]
                                         },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "35"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "36"  }
                                            ]
                                         },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "35"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "36"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "8"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "9"  }
                                            ]
                                         },
                                         {  "prim": "CAR",
                                            "args": [
                                              {  "int": "0"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "3"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "4"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "15"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "16"  }
                                            ]
                                         },
                                         {  "prim": "CDR",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "16"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "17"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "EXEC"  },
                                         {  "prim": "DIP",
                                            "args": [
                                              {  "int": "1"  },
                                              [  {  "prim": "DIG",
                                                    "args": [
                                                      {  "int": "3"  }
                                                    ]
                                              },
                                              {  "prim": "DROP",
                                                 "args": [
                                                   {  "int": "1"  }
                                                 ]
                                              }  ]
                                            ]
                                         },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "3"  }
                                            ]
                                         },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         }  ],
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "nat"  },
                                                 {  "int": "2"  }
                                               ]
                                         },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "10"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "11"  }
                                            ]
                                         },
                                         {  "prim": "COMPARE"  },
                                         {  "prim": "EQ"  },
                                         {  "prim": "IF",
                                            "args": [
                                              [  {  "prim": "DIG",
                                                    "args": [
                                                      {  "int": "23"  }
                                                    ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "24"  }
                                                 ]
                                              },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "34"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "35"  }
                                                 ]
                                              },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "32"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "33"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "31"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "32"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "30"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "31"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "29"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "30"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "38"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "39"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "34"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "35"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "28"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "29"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "27"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "28"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "26"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "27"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "33"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "34"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "10"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "11"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "16"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "17"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "15"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "16"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "7"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "8"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "6"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "7"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "2"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "3"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "14"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "15"  }
                                                 ]
                                              },
                                              {  "prim": "CDR",
                                                 "args": [
                                                   {  "int": "1"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "21"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "22"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "19"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "20"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "22"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "23"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "EXEC"  },
                                              {  "prim": "DUP"  },
                                              {  "prim": "CAR",
                                                 "args": [
                                                   {  "int": "0"  }
                                                 ]
                                              },
                                              {  "prim": "DIP",
                                                 "args": [
                                                   {  "int": "1"  },
                                                   [  {  "prim": "DIG",
                                                         "args": [
                                                           {  "int": "7"  }
                                                         ]
                                                   },
                                                   {  "prim": "DROP",
                                                      "args": [
                                                        {  "int": "1"  }
                                                      ]
                                                   }  ]
                                                 ]
                                              },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "7"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "CDR",
                                                 "args": [
                                                   {  "int": "1"  }
                                                 ]
                                              },
                                              {  "prim": "DIP",
                                                 "args": [
                                                   {  "int": "1"  },
                                                   [  {  "prim": "DIG",
                                                         "args": [
                                                           {  "int": "4"  }
                                                         ]
                                                   },
                                                   {  "prim": "DROP",
                                                      "args": [
                                                        {  "int": "1"  }
                                                      ]
                                                   }  ]
                                                 ]
                                              },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "4"  }
                                                 ]
                                              },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "32"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "33"  }
                                                 ]
                                              },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "35"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "36"  }
                                                 ]
                                              },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "35"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "36"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "7"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "8"  }
                                                 ]
                                              },
                                              {  "prim": "CAR",
                                                 "args": [
                                                   {  "int": "0"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "4"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "5"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "15"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "16"  }
                                                 ]
                                              },
                                              {  "prim": "CAR",
                                                 "args": [
                                                   {  "int": "0"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "17"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "18"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "EXEC"  },
                                              {  "prim": "DIP",
                                                 "args": [
                                                   {  "int": "1"  },
                                                   [  {  "prim": "DIG",
                                                         "args": [
                                                           {  "int": "3"  }
                                                         ]
                                                   },
                                                   {  "prim": "DROP",
                                                      "args": [
                                                        {  "int": "1"  }
                                                      ]
                                                   }  ]
                                                 ]
                                              },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "3"  }
                                                 ]
                                              },
                                              {  "prim": "DROP",
                                                 "args": [
                                                   {  "int": "1"  }
                                                 ]
                                              }  ],
                                              [  {  "prim": "DIG",
                                                    "args": [
                                                      {  "int": "31"  }
                                                    ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "32"  }
                                                 ]
                                              },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "34"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "35"  }
                                                 ]
                                              },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "34"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "35"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "6"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "7"  }
                                                 ]
                                              },
                                              {  "prim": "CAR",
                                                 "args": [
                                                   {  "int": "0"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "3"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "4"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "14"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "15"  }
                                                 ]
                                              },
                                              {  "prim": "CAR",
                                                 "args": [
                                                   {  "int": "0"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "16"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "17"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "EXEC"  },
                                              {  "prim": "DIP",
                                                 "args": [
                                                   {  "int": "1"  },
                                                   [  {  "prim": "DIG",
                                                         "args": [
                                                           {  "int": "3"  }
                                                         ]
                                                   },
                                                   {  "prim": "DROP",
                                                      "args": [
                                                        {  "int": "1"  }
                                                      ]
                                                   }  ]
                                                 ]
                                              },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "3"  }
                                                 ]
                                              },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "31"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "32"  }
                                                 ]
                                              },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "34"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "35"  }
                                                 ]
                                              },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "34"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "35"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "7"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "8"  }
                                                 ]
                                              },
                                              {  "prim": "CAR",
                                                 "args": [
                                                   {  "int": "0"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "2"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "3"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "14"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "15"  }
                                                 ]
                                              },
                                              {  "prim": "CDR",
                                                 "args": [
                                                   {  "int": "1"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "15"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "16"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "EXEC"  },
                                              {  "prim": "DIP",
                                                 "args": [
                                                   {  "int": "1"  },
                                                   [  {  "prim": "DIG",
                                                         "args": [
                                                           {  "int": "2"  }
                                                         ]
                                                   },
                                                   {  "prim": "DROP",
                                                      "args": [
                                                        {  "int": "1"  }
                                                      ]
                                                   }  ]
                                                 ]
                                              },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "2"  }
                                                 ]
                                              }  ]
                                            ]
                                         }  ]
                                       ]
                                    },
                                    {  "prim": "NIL",
                                       "args": [
                                         {  "prim": "operation"  }
                                       ]
                                    },
                                    {  "prim": "PUSH",
                                       "args": [
                                         {  "prim": "unit"  },
                                         {  "prim": "Unit"  }
                                       ]
                                    },
                                    {  "prim": "LEFT",
                                       "args": [
                                         {  "prim": "or",
                                            "args": [
                                              {  "prim": "unit"  },
                                              {  "prim": "or",
                                                 "args": [
                                                   {  "prim": "unit"  },
                                                   {  "prim": "or",
                                                      "args": [
                                                        {  "prim": "unit"  },
                                                        {  "prim": "bytes"  }
                                                      ]
                                                   }
                                                 ]
                                              }
                                            ]
                                         }
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "16"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "17"  }
                                       ]
                                    },
                                    {  "prim": "CAR",
                                       "args": [
                                         {  "int": "0"  }
                                       ]
                                    },
                                    {  "prim": "COMPARE"  },
                                    {  "prim": "EQ"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "unit"  },
                                                 {  "prim": "Unit"  }
                                               ]
                                         },
                                         {  "prim": "LEFT",
                                            "args": [
                                              {  "prim": "or",
                                                 "args": [
                                                   {  "prim": "unit"  },
                                                   {  "prim": "or",
                                                      "args": [
                                                        {  "prim": "unit"  },
                                                        {  "prim": "or",
                                                           "args": [
                                                             {  "prim": "unit"  },
                                                             {  "prim": "bytes"  }
                                                           ]
                                                        }
                                                      ]
                                                   }
                                                 ]
                                              }
                                            ]
                                         },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "15"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "16"  }
                                            ]
                                         },
                                         {  "prim": "CAR",
                                            "args": [
                                              {  "int": "0"  }
                                            ]
                                         },
                                         {  "prim": "COMPARE"  },
                                         {  "prim": "NEQ"  },
                                         {  "prim": "NOT"  },
                                         {  "prim": "IF",
                                            "args": [
                                              [  {  "prim": "PUSH",
                                                    "args": [
                                                      {  "prim": "string"  },
                                                      {  "string": "takeMatch.assetClass <> XTZ"  }
                                                    ]
                                              },
                                              {  "prim": "FAILWITH"  }  ],
                                              [    ]
                                            ]
                                         },
                                         {  "prim": "AMOUNT"  },
                                         {  "prim": "PUSH",
                                            "args": [
                                              {  "prim": "mutez"  },
                                              {  "int": "1"  }
                                            ]
                                         },
                                         {  "prim": "SWAP"  },
                                         {  "prim": "EDIV"  },
                                         {  "prim": "IF_NONE",
                                            "args": [
                                              [  {  "prim": "PUSH",
                                                    "args": [
                                                      {  "prim": "string"  },
                                                      {  "string": "DivByZero"  }
                                                    ]
                                              },
                                              {  "prim": "FAILWITH"  }  ],
                                              [    ]
                                            ]
                                         },
                                         {  "prim": "CAR",
                                            "args": [
                                              {  "int": "0"  }
                                            ]
                                         },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "9"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "10"  }
                                            ]
                                         },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "2"  }
                                            ]
                                         },
                                         {  "prim": "COMPARE"  },
                                         {  "prim": "GE"  },
                                         {  "prim": "NOT"  },
                                         {  "prim": "IF",
                                            "args": [
                                              [  {  "prim": "PUSH",
                                                    "args": [
                                                      {  "prim": "string"  },
                                                      {  "string": "not enough xtz"  }
                                                    ]
                                              },
                                              {  "prim": "FAILWITH"  }  ],
                                              [    ]
                                            ]
                                         },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "9"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "10"  }
                                            ]
                                         },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "2"  }
                                            ]
                                         },
                                         {  "prim": "COMPARE"  },
                                         {  "prim": "GT"  },
                                         {  "prim": "IF",
                                            "args": [
                                              [  {  "prim": "SOURCE"  },
                                              {  "prim": "CONTRACT",
                                                 "args": [
                                                   {  "prim": "unit"  }
                                                 ]
                                              },
                                              {  "prim": "IF_NONE",
                                                 "args": [
                                                   [  {  "prim": "PUSH",
                                                         "args": [
                                                           {  "prim": "string"  },
                                                           {  "string": "NotFound"  }
                                                         ]
                                                   },
                                                   {  "prim": "FAILWITH"  }  ],
                                                   [    ]
                                                 ]
                                              },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "1"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "2"  }
                                                 ]
                                              },
                                              {  "prim": "PUSH",
                                                 "args": [
                                                   {  "prim": "mutez"  },
                                                   {  "int": "1"  }
                                                 ]
                                              },
                                              {  "prim": "PUSH",
                                                 "args": [
                                                   {  "prim": "nat"  },
                                                   {  "int": "1"  }
                                                 ]
                                              },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "13"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "14"  }
                                                 ]
                                              },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "3"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "4"  }
                                                 ]
                                              },
                                              {  "prim": "SUB"  },
                                              {  "prim": "DUP"  },
                                              {  "prim": "PUSH",
                                                 "args": [
                                                   {  "prim": "int"  },
                                                   {  "int": "0"  }
                                                 ]
                                              },
                                              {  "prim": "COMPARE"  },
                                              {  "prim": "GT"  },
                                              {  "prim": "IF",
                                                 "args": [
                                                   [  {  "prim": "PUSH",
                                                         "args": [
                                                           {  "prim": "string"  },
                                                           {  "string": "NegResult"  }
                                                         ]
                                                   },
                                                   {  "prim": "FAILWITH"  }  ],
                                                   [    ]
                                                 ]
                                              },
                                              {  "prim": "ABS"  },
                                              {  "prim": "INT"  },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "UNPAIR"  },
                                              {  "prim": "ABS"  },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "2"  }
                                                 ]
                                              },
                                              {  "prim": "MUL"  },
                                              {  "prim": "EDIV"  },
                                              {  "prim": "IF_NONE",
                                                 "args": [
                                                   [  {  "prim": "PUSH",
                                                         "args": [
                                                           {  "prim": "string"  },
                                                           {  "string": "DivByZero"  }
                                                         ]
                                                   },
                                                   {  "prim": "FAILWITH"  }  ],
                                                   [    ]
                                                 ]
                                              },
                                              {  "prim": "CAR",
                                                 "args": [
                                                   {  "int": "0"  }
                                                 ]
                                              },
                                              {  "prim": "NIL",
                                                 "args": [
                                                   {  "prim": "operation"  }
                                                 ]
                                              },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "3"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "4"  }
                                                 ]
                                              },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "2"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "3"  }
                                                 ]
                                              },
                                              {  "prim": "PUSH",
                                                 "args": [
                                                   {  "prim": "unit"  },
                                                   {  "prim": "Unit"  }
                                                 ]
                                              },
                                              {  "prim": "TRANSFER_TOKENS"  },
                                              {  "prim": "CONS"  },
                                              {  "prim": "DIP",
                                                 "args": [
                                                   {  "int": "1"  },
                                                   [  {  "prim": "DIG",
                                                         "args": [
                                                           {  "int": "4"  }
                                                         ]
                                                   },
                                                   {  "prim": "DROP",
                                                      "args": [
                                                        {  "int": "1"  }
                                                      ]
                                                   }  ]
                                                 ]
                                              },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "4"  }
                                                 ]
                                              },
                                              {  "prim": "DROP",
                                                 "args": [
                                                   {  "int": "3"  }
                                                 ]
                                              }  ],
                                              [    ]
                                            ]
                                         },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         }  ],
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "unit"  },
                                                 {  "prim": "Unit"  }
                                               ]
                                         },
                                         {  "prim": "LEFT",
                                            "args": [
                                              {  "prim": "or",
                                                 "args": [
                                                   {  "prim": "unit"  },
                                                   {  "prim": "or",
                                                      "args": [
                                                        {  "prim": "unit"  },
                                                        {  "prim": "or",
                                                           "args": [
                                                             {  "prim": "unit"  },
                                                             {  "prim": "bytes"  }
                                                           ]
                                                        }
                                                      ]
                                                   }
                                                 ]
                                              }
                                            ]
                                         },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "15"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "16"  }
                                            ]
                                         },
                                         {  "prim": "CAR",
                                            "args": [
                                              {  "int": "0"  }
                                            ]
                                         },
                                         {  "prim": "COMPARE"  },
                                         {  "prim": "EQ"  },
                                         {  "prim": "IF",
                                            "args": [
                                              [  {  "prim": "AMOUNT"  },
                                              {  "prim": "PUSH",
                                                 "args": [
                                                   {  "prim": "mutez"  },
                                                   {  "int": "1"  }
                                                 ]
                                              },
                                              {  "prim": "SWAP"  },
                                              {  "prim": "EDIV"  },
                                              {  "prim": "IF_NONE",
                                                 "args": [
                                                   [  {  "prim": "PUSH",
                                                         "args": [
                                                           {  "prim": "string"  },
                                                           {  "string": "DivByZero"  }
                                                         ]
                                                   },
                                                   {  "prim": "FAILWITH"  }  ],
                                                   [    ]
                                                 ]
                                              },
                                              {  "prim": "CAR",
                                                 "args": [
                                                   {  "int": "0"  }
                                                 ]
                                              },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "8"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "9"  }
                                                 ]
                                              },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "1"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "2"  }
                                                 ]
                                              },
                                              {  "prim": "COMPARE"  },
                                              {  "prim": "GE"  },
                                              {  "prim": "NOT"  },
                                              {  "prim": "IF",
                                                 "args": [
                                                   [  {  "prim": "PUSH",
                                                         "args": [
                                                           {  "prim": "string"  },
                                                           {  "string": "not enough xtz"  }
                                                         ]
                                                   },
                                                   {  "prim": "FAILWITH"  }  ],
                                                   [    ]
                                                 ]
                                              },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "8"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "9"  }
                                                 ]
                                              },
                                              {  "prim": "DIG",
                                                 "args": [
                                                   {  "int": "1"  }
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "DUG",
                                                 "args": [
                                                   {  "int": "2"  }
                                                 ]
                                              },
                                              {  "prim": "COMPARE"  },
                                              {  "prim": "GT"  },
                                              {  "prim": "IF",
                                                 "args": [
                                                   [  {  "prim": "SOURCE"  },
                                                   {  "prim": "CONTRACT",
                                                      "args": [
                                                        {  "prim": "unit"  }
                                                      ]
                                                   },
                                                   {  "prim": "IF_NONE",
                                                      "args": [
                                                        [  {  "prim": "PUSH",
                                                              "args": [
                                                                {  "prim": "string"  },
                                                                {  "string": "NotFound"  }
                                                              ]
                                                        },
                                                        {  "prim": "FAILWITH"  }  ],
                                                        [    ]
                                                      ]
                                                   },
                                                   {  "prim": "DIG",
                                                      "args": [
                                                        {  "int": "1"  }
                                                      ]
                                                   },
                                                   {  "prim": "DUP"  },
                                                   {  "prim": "DUG",
                                                      "args": [
                                                        {  "int": "2"  }
                                                      ]
                                                   },
                                                   {  "prim": "PUSH",
                                                      "args": [
                                                        {  "prim": "mutez"  },
                                                        {  "int": "1"  }
                                                      ]
                                                   },
                                                   {  "prim": "PUSH",
                                                      "args": [
                                                        {  "prim": "nat"  },
                                                        {  "int": "1"  }
                                                      ]
                                                   },
                                                   {  "prim": "DIG",
                                                      "args": [
                                                        {  "int": "12"  }
                                                      ]
                                                   },
                                                   {  "prim": "DUP"  },
                                                   {  "prim": "DUG",
                                                      "args": [
                                                        {  "int": "13"  }
                                                      ]
                                                   },
                                                   {  "prim": "DIG",
                                                      "args": [
                                                        {  "int": "3"  }
                                                      ]
                                                   },
                                                   {  "prim": "DUP"  },
                                                   {  "prim": "DUG",
                                                      "args": [
                                                        {  "int": "4"  }
                                                      ]
                                                   },
                                                   {  "prim": "SUB"  },
                                                   {  "prim": "DUP"  },
                                                   {  "prim": "PUSH",
                                                      "args": [
                                                        {  "prim": "int"  },
                                                        {  "int": "0"  }
                                                      ]
                                                   },
                                                   {  "prim": "COMPARE"  },
                                                   {  "prim": "GT"  },
                                                   {  "prim": "IF",
                                                      "args": [
                                                        [  {  "prim": "PUSH",
                                                              "args": [
                                                                {  "prim": "string"  },
                                                                {  "string": "NegResult"  }
                                                              ]
                                                        },
                                                        {  "prim": "FAILWITH"  }  ],
                                                        [    ]
                                                      ]
                                                   },
                                                   {  "prim": "ABS"  },
                                                   {  "prim": "INT"  },
                                                   {  "prim": "PAIR"  },
                                                   {  "prim": "UNPAIR"  },
                                                   {  "prim": "ABS"  },
                                                   {  "prim": "DIG",
                                                      "args": [
                                                        {  "int": "2"  }
                                                      ]
                                                   },
                                                   {  "prim": "MUL"  },
                                                   {  "prim": "EDIV"  },
                                                   {  "prim": "IF_NONE",
                                                      "args": [
                                                        [  {  "prim": "PUSH",
                                                              "args": [
                                                                {  "prim": "string"  },
                                                                {  "string": "DivByZero"  }
                                                              ]
                                                        },
                                                        {  "prim": "FAILWITH"  }  ],
                                                        [    ]
                                                      ]
                                                   },
                                                   {  "prim": "CAR",
                                                      "args": [
                                                        {  "int": "0"  }
                                                      ]
                                                   },
                                                   {  "prim": "NIL",
                                                      "args": [
                                                        {  "prim": "operation"  }
                                                      ]
                                                   },
                                                   {  "prim": "DIG",
                                                      "args": [
                                                        {  "int": "3"  }
                                                      ]
                                                   },
                                                   {  "prim": "DUP"  },
                                                   {  "prim": "DUG",
                                                      "args": [
                                                        {  "int": "4"  }
                                                      ]
                                                   },
                                                   {  "prim": "DIG",
                                                      "args": [
                                                        {  "int": "2"  }
                                                      ]
                                                   },
                                                   {  "prim": "DUP"  },
                                                   {  "prim": "DUG",
                                                      "args": [
                                                        {  "int": "3"  }
                                                      ]
                                                   },
                                                   {  "prim": "PUSH",
                                                      "args": [
                                                        {  "prim": "unit"  },
                                                        {  "prim": "Unit"  }
                                                      ]
                                                   },
                                                   {  "prim": "TRANSFER_TOKENS"  },
                                                   {  "prim": "CONS"  },
                                                   {  "prim": "DIP",
                                                      "args": [
                                                        {  "int": "1"  },
                                                        [  {  "prim": "DIG",
                                                              "args": [
                                                                {  "int": "4"  }
                                                              ]
                                                        },
                                                        {  "prim": "DROP",
                                                           "args": [
                                                             {  "int": "1"  }
                                                           ]
                                                        }  ]
                                                      ]
                                                   },
                                                   {  "prim": "DUG",
                                                      "args": [
                                                        {  "int": "4"  }
                                                      ]
                                                   },
                                                   {  "prim": "DROP",
                                                      "args": [
                                                        {  "int": "3"  }
                                                      ]
                                                   }  ],
                                                   [    ]
                                                 ]
                                              },
                                              {  "prim": "DROP",
                                                 "args": [
                                                   {  "int": "1"  }
                                                 ]
                                              }  ],
                                              [    ]
                                            ]
                                         }  ]
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "NIL",
                                       "args": [
                                         {  "prim": "operation"  }
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "5"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "6"  }
                                       ]
                                    },
                                    {  "prim": "ITER",
                                       "args": [
                                         [  {  "prim": "DIG",
                                               "args": [
                                                 {  "int": "1"  }
                                               ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "2"  }
                                            ]
                                         },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "2"  }
                                            ]
                                         },
                                         {  "prim": "CONS"  },
                                         {  "prim": "DIP",
                                            "args": [
                                              {  "int": "1"  },
                                              [  {  "prim": "DIG",
                                                    "args": [
                                                      {  "int": "1"  }
                                                    ]
                                              },
                                              {  "prim": "DROP",
                                                 "args": [
                                                   {  "int": "1"  }
                                                 ]
                                              }  ]
                                            ]
                                         },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         }  ]
                                       ]
                                    },
                                    {  "prim": "ITER",
                                       "args": [
                                         [  {  "prim": "DIG",
                                               "args": [
                                                 {  "int": "1"  }
                                               ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "2"  }
                                            ]
                                         },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "2"  }
                                            ]
                                         },
                                         {  "prim": "CONS"  },
                                         {  "prim": "DIP",
                                            "args": [
                                              {  "int": "1"  },
                                              [  {  "prim": "DIG",
                                                    "args": [
                                                      {  "int": "1"  }
                                                    ]
                                              },
                                              {  "prim": "DROP",
                                                 "args": [
                                                   {  "int": "1"  }
                                                 ]
                                              }  ]
                                            ]
                                         },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         }  ]
                                       ]
                                    },
                                    {  "prim": "NIL",
                                       "args": [
                                         {  "prim": "operation"  }
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "6"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "7"  }
                                       ]
                                    },
                                    {  "prim": "ITER",
                                       "args": [
                                         [  {  "prim": "DIG",
                                               "args": [
                                                 {  "int": "1"  }
                                               ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "2"  }
                                            ]
                                         },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "2"  }
                                            ]
                                         },
                                         {  "prim": "CONS"  },
                                         {  "prim": "DIP",
                                            "args": [
                                              {  "int": "1"  },
                                              [  {  "prim": "DIG",
                                                    "args": [
                                                      {  "int": "1"  }
                                                    ]
                                              },
                                              {  "prim": "DROP",
                                                 "args": [
                                                   {  "int": "1"  }
                                                 ]
                                              }  ]
                                            ]
                                         },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         }  ]
                                       ]
                                    },
                                    {  "prim": "ITER",
                                       "args": [
                                         [  {  "prim": "DIG",
                                               "args": [
                                                 {  "int": "1"  }
                                               ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "2"  }
                                            ]
                                         },
                                         {  "prim": "DIG",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         },
                                         {  "prim": "DUP"  },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "2"  }
                                            ]
                                         },
                                         {  "prim": "CONS"  },
                                         {  "prim": "DIP",
                                            "args": [
                                              {  "int": "1"  },
                                              [  {  "prim": "DIG",
                                                    "args": [
                                                      {  "int": "1"  }
                                                    ]
                                              },
                                              {  "prim": "DROP",
                                                 "args": [
                                                   {  "int": "1"  }
                                                 ]
                                              }  ]
                                            ]
                                         },
                                         {  "prim": "DUG",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         }  ]
                                       ]
                                    },
                                    {  "prim": "DIP",
                                       "args": [
                                         {  "int": "1"  },
                                         [  {  "prim": "DIG",
                                               "args": [
                                                 {  "int": "23"  }
                                               ]
                                         },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         }  ]
                                       ]
                                    },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "23"  }
                                       ]
                                    },
                                    {  "prim": "PUSH",
                                       "args": [
                                         {  "prim": "nat"  },
                                         {  "int": "0"  }
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "24"  }
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "25"  }
                                       ]
                                    },
                                    {  "prim": "SIZE"  },
                                    {  "prim": "COMPARE"  },
                                    {  "prim": "GT"  },
                                    {  "prim": "NOT"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "no operation to send"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DROP",
                                       "args": [
                                         {  "int": "16"  }
                                       ]
                                    },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "PAIR"  }  ]
                                  ]
                            }  ]
                          ]
                    }  ],
                    [  {  "prim": "UNPAIR"  },
                    {  "prim": "SWAP"  },
                    {  "prim": "UNPAIR"  },
                    {  "prim": "SWAP"  },
                    {  "prim": "UNPAIR"  },
                    {  "prim": "SWAP"  },
                    {  "prim": "DIG",
                       "args": [
                         {  "int": "5"  }
                       ]
                    },
                    {  "prim": "DUP"  },
                    {  "prim": "DUG",
                       "args": [
                         {  "int": "6"  }
                       ]
                    },
                    {  "prim": "IF_NONE",
                       "args": [
                         [  {  "prim": "PUSH",
                               "args": [
                                 {  "prim": "bool"  },
                                 {  "prim": "False"  }
                               ]
                         }  ],
                         [  {  "prim": "PUSH",
                               "args": [
                                 {  "prim": "bool"  },
                                 {  "prim": "True"  }
                               ]
                         },
                         {  "prim": "SWAP"  },
                         {  "prim": "DROP",
                            "args": [
                              {  "int": "1"  }
                            ]
                         }  ]
                       ]
                    },
                    {  "prim": "NOT"  },
                    {  "prim": "IF",
                       "args": [
                         [  {  "prim": "PUSH",
                               "args": [
                                 {  "prim": "string"  },
                                 {  "string": "validator is unset"  }
                               ]
                         },
                         {  "prim": "FAILWITH"  }  ],
                         [    ]
                       ]
                    },
                    {  "prim": "DIG",
                       "args": [
                         {  "int": "11"  }
                       ]
                    },
                    {  "prim": "DUP"  },
                    {  "prim": "DUG",
                       "args": [
                         {  "int": "12"  }
                       ]
                    },
                    {  "prim": "DIG",
                       "args": [
                         {  "int": "6"  }
                       ]
                    },
                    {  "prim": "DUP"  },
                    {  "prim": "DUG",
                       "args": [
                         {  "int": "7"  }
                       ]
                    },
                    {  "prim": "IF_NONE",
                       "args": [
                         [  {  "prim": "PUSH",
                               "args": [
                                 {  "prim": "string"  },
                                 {  "string": "NotFound"  }
                               ]
                         },
                         {  "prim": "FAILWITH"  }  ],
                         [    ]
                       ]
                    },
                    {  "prim": "CONTRACT",
                       "args": [
                         {  "prim": "pair",
                            "args": [
                              {  "prim": "pair",
                                 "args": [
                                   {  "prim": "option",
                                      "args": [
                                        {  "prim": "key"  }
                                      ]
                                   },
                                   {  "prim": "pair",
                                      "args": [
                                        {  "prim": "pair",
                                           "args": [
                                             {  "prim": "pair",
                                                "args": [
                                                  {  "prim": "or",
                                                     "args": [
                                                       {  "prim": "unit"  },
                                                       {  "prim": "or",
                                                          "args": [
                                                            {  "prim": "unit"  },
                                                            {  "prim": "or",
                                                               "args": [
                                                                 {  "prim": "unit"  },
                                                                 {  "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "unit"  },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                 }
                                                               ]
                                                            }
                                                          ]
                                                       }
                                                     ]
                                                  },
                                                  {  "prim": "bytes"  }
                                                ]
                                             },
                                             {  "prim": "nat"  }
                                           ]
                                        },
                                        {  "prim": "pair",
                                           "args": [
                                             {  "prim": "option",
                                                "args": [
                                                  {  "prim": "key"  }
                                                ]
                                             },
                                             {  "prim": "pair",
                                                "args": [
                                                  {  "prim": "pair",
                                                     "args": [
                                                       {  "prim": "pair",
                                                          "args": [
                                                            {  "prim": "or",
                                                               "args": [
                                                                 {  "prim": "unit"  },
                                                                 {  "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "unit"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "unit"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "unit"  },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                    }
                                                                    ]
                                                                    }
                                                                    ]
                                                                 }
                                                               ]
                                                            },
                                                            {  "prim": "bytes"  }
                                                          ]
                                                       },
                                                       {  "prim": "nat"  }
                                                     ]
                                                  },
                                                  {  "prim": "pair",
                                                     "args": [
                                                       {  "prim": "nat"  },
                                                       {  "prim": "pair",
                                                          "args": [
                                                            {  "prim": "option",
                                                               "args": [
                                                                 {  "prim": "timestamp"  }
                                                               ]
                                                            },
                                                            {  "prim": "pair",
                                                               "args": [
                                                                 {  "prim": "option",
                                                                    "args": [

                                                                    {  "prim": "timestamp"  }
                                                                    ]
                                                                 },
                                                                 {  "prim": "pair",
                                                                    "args": [

                                                                    {  "prim": "bytes"  },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                 }
                                                               ]
                                                            }
                                                          ]
                                                       }
                                                     ]
                                                  }
                                                ]
                                             }
                                           ]
                                        }
                                      ]
                                   }
                                 ]
                              },
                              {  "prim": "pair",
                                 "args": [
                                   {  "prim": "option",
                                      "args": [
                                        {  "prim": "signature"  }
                                      ]
                                   },
                                   {  "prim": "pair",
                                      "args": [
                                        {  "prim": "pair",
                                           "args": [
                                             {  "prim": "option",
                                                "args": [
                                                  {  "prim": "key"  }
                                                ]
                                             },
                                             {  "prim": "pair",
                                                "args": [
                                                  {  "prim": "pair",
                                                     "args": [
                                                       {  "prim": "pair",
                                                          "args": [
                                                            {  "prim": "or",
                                                               "args": [
                                                                 {  "prim": "unit"  },
                                                                 {  "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "unit"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "unit"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "unit"  },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                    }
                                                                    ]
                                                                    }
                                                                    ]
                                                                 }
                                                               ]
                                                            },
                                                            {  "prim": "bytes"  }
                                                          ]
                                                       },
                                                       {  "prim": "nat"  }
                                                     ]
                                                  },
                                                  {  "prim": "pair",
                                                     "args": [
                                                       {  "prim": "option",
                                                          "args": [
                                                            {  "prim": "key"  }
                                                          ]
                                                       },
                                                       {  "prim": "pair",
                                                          "args": [
                                                            {  "prim": "pair",
                                                               "args": [
                                                                 {  "prim": "pair",
                                                                    "args": [

                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "unit"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "unit"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "unit"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "unit"  },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                    }
                                                                    ]
                                                                    }
                                                                    ]
                                                                    }
                                                                    ]
                                                                    },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                 },
                                                                 {  "prim": "nat"  }
                                                               ]
                                                            },
                                                            {  "prim": "pair",
                                                               "args": [
                                                                 {  "prim": "nat"  },
                                                                 {  "prim": "pair",
                                                                    "args": [

                                                                    {
                                                                    "prim": "option",
                                                                    "args": [

                                                                    {  "prim": "timestamp"  }
                                                                    ]
                                                                    },
                                                                    {
                                                                    "prim": "pair",
                                                                    "args": [

                                                                    {
                                                                    "prim": "option",
                                                                    "args": [

                                                                    {  "prim": "timestamp"  }
                                                                    ]
                                                                    },
                                                                    {
                                                                    "prim": "pair",
                                                                    "args": [

                                                                    {  "prim": "bytes"  },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                    }
                                                                    ]
                                                                    }
                                                                    ]
                                                                 }
                                                               ]
                                                            }
                                                          ]
                                                       }
                                                     ]
                                                  }
                                                ]
                                             }
                                           ]
                                        },
                                        {  "prim": "option",
                                           "args": [
                                             {  "prim": "signature"  }
                                           ]
                                        }
                                      ]
                                   }
                                 ]
                              }
                            ]
                         }
                       ]
                       ,
                       "annots": [
                         "%matchOrders"
                       ]
                    },
                    {  "prim": "IF_NONE",
                       "args": [
                         [  {  "prim": "PUSH",
                               "args": [
                                 {  "prim": "string"  },
                                 {  "string": "NotFound"  }
                               ]
                         },
                         {  "prim": "FAILWITH"  }  ],
                         [    ]
                       ]
                    },
                    {  "prim": "AMOUNT"  },
                    {  "prim": "DIG",
                       "args": [
                         {  "int": "3"  }
                       ]
                    },
                    {  "prim": "DUP"  },
                    {  "prim": "DUG",
                       "args": [
                         {  "int": "4"  }
                       ]
                    },
                    {  "prim": "DIG",
                       "args": [
                         {  "int": "5"  }
                       ]
                    },
                    {  "prim": "DUP"  },
                    {  "prim": "DUG",
                       "args": [
                         {  "int": "6"  }
                       ]
                    },
                    {  "prim": "PAIR"  },
                    {  "prim": "DIG",
                       "args": [
                         {  "int": "6"  }
                       ]
                    },
                    {  "prim": "DUP"  },
                    {  "prim": "DUG",
                       "args": [
                         {  "int": "7"  }
                       ]
                    },
                    {  "prim": "PAIR"  },
                    {  "prim": "DIG",
                       "args": [
                         {  "int": "7"  }
                       ]
                    },
                    {  "prim": "DUP"  },
                    {  "prim": "DUG",
                       "args": [
                         {  "int": "8"  }
                       ]
                    },
                    {  "prim": "PAIR"  },
                    {  "prim": "TRANSFER_TOKENS"  },
                    {  "prim": "CONS"  },
                    {  "prim": "DIP",
                       "args": [
                         {  "int": "1"  },
                         [  {  "prim": "DIG",
                               "args": [
                                 {  "int": "11"  }
                               ]
                         },
                         {  "prim": "DROP",
                            "args": [
                              {  "int": "1"  }
                            ]
                         }  ]
                       ]
                    },
                    {  "prim": "DUG",
                       "args": [
                         {  "int": "11"  }
                       ]
                    },
                    {  "prim": "DROP",
                       "args": [
                         {  "int": "4"  }
                       ]
                    },
                    {  "prim": "SWAP"  },
                    {  "prim": "PAIR"  },
                    {  "prim": "SWAP"  },
                    {  "prim": "PAIR"  },
                    {  "prim": "SWAP"  },
                    {  "prim": "PAIR"  },
                    {  "prim": "SWAP"  },
                    {  "prim": "PAIR"  },
                    {  "prim": "SWAP"  },
                    {  "prim": "PAIR"  },
                    {  "prim": "SWAP"  },
                    {  "prim": "PAIR"  },
                    {  "prim": "DIG",
                       "args": [
                         {  "int": "1"  }
                       ]
                    },
                    {  "prim": "PAIR"  }  ]
                  ]
            }  ]
          ]
       },
       {  "prim": "DIP",
          "args": [
            {  "int": "1"  },
            [  {  "prim": "DROP",
                  "args": [
                    {  "int": "14"  }
                  ]
            }  ]
          ]
       }  ]
     ]
  }  ]

export function exchangeV2_storage(owner: string, defaultFeeReceiver: string, protocolFee: BigNumber) : any {
  return {  "prim": "Pair",
            "args": [
              {  "string": owner  },
              {  "prim": "Pair",
                 "args": [
                   {  "string": defaultFeeReceiver  },
                   {  "prim": "Pair",
                      "args": [
                        {"int": protocolFee.toString()},
                        {  "prim": "Pair",
                           "args": [
                             {  "prim": "None"  },
                             {  "prim": "Pair",
                                "args": [
                                  [    ],
                                  {  "prim": "Pair",
                                     "args": [
                                       {  "prim": "None"  },
                                       [  {  "prim": "Elt",
                                             "args": [
                                               {  "string": ""  },
                                               {  "bytes": ""  }
                                             ]
                                       }  ]
                                     ]
                                  }
                                ]
                             }
                           ]
                        }
                      ]
                   }
                 ]
              }
            ]
         }
  }

export async function deploy_exchangeV2(
  provider : Provider,
  owner: string,
  receiver: string,
  fee: BigNumber
) : Promise<OperationResult> {
  const init = exchangeV2_storage(owner, receiver, fee)
  return provider.tezos.originate({init, code: exchangeV2_code})
}
