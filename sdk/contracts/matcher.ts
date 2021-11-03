import { Provider, OperationResult } from "../common/base"

export const matcher_code : any =
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
                         "%validator"
                       ]
                    },
                    {  "prim": "option",
                       "args": [
                         {  "prim": "address"  }
                       ]
                       ,
                       "annots": [
                         "%owner_candidate"
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
                 {  "prim": "pair",
                    "args": [
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
                                               {  "prim": "nat",
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
                                                         {  "prim": "nat",
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
                                "%orderLeft"
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
                                               {  "prim": "nat",
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
                                                         {  "prim": "nat",
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
                                "%orderRight"
                              ]
                           }
                         ]
                      },
                      {  "prim": "contract",
                         "args": [
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
                                                    {  "prim": "nat",
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
                                                              {  "prim": "nat",
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
                                     "%orderL"
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
                                                         {  "prim": "nat",
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
                                                                   {
                                                                   "prim": "nat",
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
                                          "%orderR"
                                        ]
                                     },
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "option",
                                             "args": [
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "nat",
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
                                               }
                                             ]
                                             ,
                                             "annots": [
                                               "%makeMatch"
                                             ]
                                          },
                                          {  "prim": "option",
                                             "args": [
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "nat",
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
                                               }
                                             ]
                                             ,
                                             "annots": [
                                               "%takeMatch"
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
                      "%matchAssets"
                    ]
                 },
                 {  "prim": "address",
                    "annots": [
                      "%transferOwnership"
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
                 {  "prim": "address",
                    "annots": [
                      "%setValidator"
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
       [  {  "prim": "NIL",
             "args": [
               {  "prim": "operation"  }
             ]
       },
       {  "prim": "DIG",
          "args": [
            {  "int": "1"  }
          ]
       },
       {  "prim": "UNPAIR"  },
       {  "prim": "DIP",
          "args": [
            {  "int": "1"  },
            [  {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  }  ]
          ]
       },
       {  "prim": "IF_LEFT",
          "args": [
            [  {  "prim": "IF_LEFT",
                  "args": [
                    [  {  "prim": "UNPAIR"  },
                    {  "prim": "UNPAIR"  },
                    {  "prim": "SWAP"  },
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
                    {  "prim": "SENDER"  },
                    {  "prim": "COMPARE"  },
                    {  "prim": "EQ"  },
                    {  "prim": "NOT"  },
                    {  "prim": "IF",
                       "args": [
                         [  {  "prim": "PUSH",
                               "args": [
                                 {  "prim": "string"  },
                                 {  "string": "caller must be validator"  }
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
                    {  "prim": "CAR",
                       "args": [
                         {  "int": "1"  }
                       ]
                    },
                    {  "prim": "CAR",
                       "args": [
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
                         {  "int": "1"  }
                       ]
                    },
                    {  "prim": "CAR",
                       "args": [
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
                         {  "int": "3"  }
                       ]
                    },
                    {  "prim": "CAR",
                       "args": [
                         {  "int": "0"  }
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
                         {  "int": "3"  }
                       ]
                    },
                    {  "prim": "CAR",
                       "args": [
                         {  "int": "0"  }
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
                         {  "int": "7"  }
                       ]
                    },
                    {  "prim": "DUP"  },
                    {  "prim": "DUG",
                       "args": [
                         {  "int": "8"  }
                       ]
                    },
                    {  "prim": "AMOUNT"  },
                    {  "prim": "NONE",
                       "args": [
                         {  "prim": "pair",
                            "args": [
                              {  "prim": "nat"  },
                              {  "prim": "bytes"  }
                            ]
                         }
                       ]
                    },
                    {  "prim": "NONE",
                       "args": [
                         {  "prim": "pair",
                            "args": [
                              {  "prim": "nat"  },
                              {  "prim": "bytes"  }
                            ]
                         }
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
                    {  "prim": "TRANSFER_TOKENS"  },
                    {  "prim": "CONS"  },
                    {  "prim": "DIP",
                       "args": [
                         {  "int": "1"  },
                         [  {  "prim": "DIG",
                               "args": [
                                 {  "int": "10"  }
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
                         {  "int": "10"  }
                       ]
                    },
                    {  "prim": "DROP",
                       "args": [
                         {  "int": "7"  }
                       ]
                    },
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
                            {  "int": "3"  }
                          ]
                    },
                    {  "prim": "DUP"  },
                    {  "prim": "DUG",
                       "args": [
                         {  "int": "4"  }
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
                    {  "prim": "DUP"  },
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
                    {  "prim": "DUP"  },
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
                    {  "prim": "NONE",
                       "args": [
                         {  "prim": "address"  }
                       ]
                    },
                    {  "prim": "SWAP"  },
                    {  "prim": "DROP",
                       "args": [
                         {  "int": "1"  }
                       ]
                    },
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
                            {  "int": "3"  }
                          ]
                    },
                    {  "prim": "DUP"  },
                    {  "prim": "DUG",
                       "args": [
                         {  "int": "4"  }
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
  }  ]

export function matcher_storage(owner: string, validator: string) : any {
  return {  "prim": "Pair",
            "args": [
              {  "string": owner  },
              {  "prim": "Pair",
                 "args": [
                   {  "string": validator  },
                   {  "prim": "None"  }
                 ]
              }
            ]
         }
}

export async function deploy_matcher(
  provider : Provider,
  owner: string,
  validator: string,
) : Promise<OperationResult> {
  const init = matcher_storage(owner, validator)
  return provider.tezos.originate({init, code: matcher_code})
}
