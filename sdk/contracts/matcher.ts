import { Provider, OperationResult } from "../common/base"

export const matcher_code : any =
  [  {  "prim": "storage",
        "args": [
          {  "prim": "unit"  }
        ]
  },
  {  "prim": "parameter",
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
                                     {  "prim": "int",
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
                                               {  "prim": "int",
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
                                     {  "prim": "int",
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
                                               {  "prim": "int",
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
                                          {  "prim": "int",
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
                                                    {  "prim": "int",
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
                                               {  "prim": "int",
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
                                                         {  "prim": "int",
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
                                "%orderR"
                              ]
                           },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "option",
                                   "args": [
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "int",
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
                                          {  "prim": "int",
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
       {  "prim": "UNPAIR"  },
       {  "prim": "UNPAIR"  },
       {  "prim": "SWAP"  },
       {  "prim": "DUP",
          "args": [
            {  "int": "2"  }
          ]
       },
       {  "prim": "CDR"  },
       {  "prim": "CAR"  },
       {  "prim": "CAR"  },
       {  "prim": "DUP",
          "args": [
            {  "int": "3"  }
          ]
       },
       {  "prim": "CDR"  },
       {  "prim": "CAR"  },
       {  "prim": "CAR"  },
       {  "prim": "DUP",
          "args": [
            {  "int": "3"  }
          ]
       },
       {  "prim": "CDR"  },
       {  "prim": "CDR"  },
       {  "prim": "CDR"  },
       {  "prim": "CAR"  },
       {  "prim": "CAR"  },
       {  "prim": "DUP",
          "args": [
            {  "int": "4"  }
          ]
       },
       {  "prim": "CDR"  },
       {  "prim": "CDR"  },
       {  "prim": "CDR"  },
       {  "prim": "CAR"  },
       {  "prim": "CAR"  },
       {  "prim": "DUP",
          "args": [
            {  "int": "9"  }
          ]
       },
       {  "prim": "DUP",
          "args": [
            {  "int": "8"  }
          ]
       },
       {  "prim": "AMOUNT"  },
       {  "prim": "NONE",
          "args": [
            {  "prim": "pair",
               "args": [
                 {  "prim": "int"  },
                 {  "prim": "bytes"  }
               ]
            }
          ]
       },
       {  "prim": "NONE",
          "args": [
            {  "prim": "pair",
               "args": [
                 {  "prim": "int"  },
                 {  "prim": "bytes"  }
               ]
            }
          ]
       },
       {  "prim": "PAIR"  },
       {  "prim": "DUP",
          "args": [
            {  "int": "9"  }
          ]
       },
       {  "prim": "PAIR"  },
       {  "prim": "DUP",
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
            {  "int": "7"  }
          ]
       },
       {  "prim": "DIG",
          "args": [
            {  "int": "1"  }
          ]
       },
       {  "prim": "PAIR"  }  ]
     ]
  }  ]


export function matcher_storage() : any {
  return {  "prim": "Unit"  }
}

export async function deploy_matcher(
  provider : Provider,
) : Promise<OperationResult> {
  const init = matcher_storage()
  return provider.tezos.originate({init, code: matcher_code})
}
