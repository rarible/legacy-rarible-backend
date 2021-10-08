import { Provider, OperationResult } from "../common/base"

export const validator_code =
  [  {  "prim": "storage",
        "args": [
          {  "prim": "pair",
             "args": [
               {  "prim": "address",
                  "annots": [
                    "%exchangeV2"
                  ]
               },
               {  "prim": "pair",
                  "args": [
                    {  "prim": "address",
                       "annots": [
                         "%royaltiesContract"
                       ]
                    },
                    {  "prim": "pair",
                       "args": [
                         {  "prim": "big_map",
                            "args": [
                              {  "prim": "bytes"  },
                              {  "prim": "nat"  }
                            ]
                            ,
                            "annots": [
                              "%fill"
                            ]
                         },
                         {  "prim": "pair",
                            "args": [
                              {  "prim": "set",
                                 "args": [
                                   {  "prim": "address"  }
                                 ]
                                 ,
                                 "annots": [
                                   "%matcher"
                                 ]
                              },
                              {  "prim": "pair",
                                 "args": [
                                   {  "prim": "map",
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
                                      ,
                                      "annots": [
                                        "%asset_class_matcher"
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
  },
  {  "prim": "parameter",
     "args": [
       {  "prim": "or",
          "args": [
            {  "prim": "or",
               "args": [
                 {  "prim": "or",
                    "args": [
                      {  "prim": "address",
                         "annots": [
                           "%setRoyaltiesContract"
                         ]
                      },
                      {  "prim": "bytes",
                         "annots": [
                           "%setMetadataUri"
                         ]
                      }
                    ]
                 },
                 {  "prim": "or",
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
                           "%cancel"
                         ]
                      },
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
                      }
                    ]
                 }
               ]
            },
            {  "prim": "or",
               "args": [
                 {  "prim": "or",
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
                                "%orderLeft"
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
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "option",
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
                                          }
                                        ]
                                        ,
                                        "annots": [
                                          "%imakeMatch"
                                        ]
                                     },
                                     {  "prim": "option",
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
                                          }
                                        ]
                                        ,
                                        "annots": [
                                          "%itakeMatch"
                                        ]
                                     }
                                   ]
                                }
                              ]
                           }
                         ]
                         ,
                         "annots": [
                           "%matchAndTransfer"
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
                                "%r"
                              ]
                           },
                           {  "prim": "bytes",
                              "annots": [
                                "%idata"
                              ]
                           }
                         ]
                         ,
                         "annots": [
                           "%processRoyalities"
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
               {  "prim": "bytes"  },
               [  {  "prim": "PUSH",
                     "args": [
                       {  "prim": "unit"  },
                       {  "prim": "Unit"  }
                     ]
               },
               {  "prim": "NIL",
                  "args": [
                    {  "prim": "bytes"  }
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
                    {  "int": "4"  }
                  ]
               },
               {  "prim": "PACK"  },
               {  "prim": "CONS"  },
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
               {  "prim": "PACK"  },
               {  "prim": "KECCAK"  },
               {  "prim": "CONS"  },
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
               {  "prim": "PACK"  },
               {  "prim": "KECCAK"  },
               {  "prim": "CONS"  },
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
               {  "prim": "PACK"  },
               {  "prim": "CONS"  },
               {  "prim": "CONCAT"  },
               {  "prim": "KECCAK"  },
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
                 {  "prim": "nat"  },
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "nat"  },
                      {  "prim": "nat"  }
                    ]
                 }
               ]
            },
            {  "prim": "nat"  },
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
            {  "prim": "MUL"  },
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
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUG",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "EDIV"  },
            {  "prim": "IF_NONE",
               "args": [
                 [  {  "prim": "PUSH",
                       "args": [
                         {  "prim": "string"  },
                         {  "string": "division by zero"  }
                       ]
                 },
                 {  "prim": "FAILWITH"  }  ],
                 [  {  "prim": "PUSH",
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
                 {  "prim": "COMPARE"  },
                 {  "prim": "NEQ"  },
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
                      {  "prim": "PUSH",
                         "args": [
                           {  "prim": "nat"  },
                           {  "int": "1000"  }
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
                      {  "prim": "MUL"  },
                      {  "prim": "COMPARE"  },
                      {  "prim": "GE"  },
                      {  "prim": "IF",
                         "args": [
                           [  {  "prim": "PUSH",
                                 "args": [
                                   {  "prim": "string"  },
                                   {  "string": "rounding error"  }
                                 ]
                           },
                           {  "prim": "FAILWITH"  }  ],
                           [    ]
                         ]
                      }  ],
                      [    ]
                    ]
                 },
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
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "nat"  },
                      {  "prim": "lambda",
                         "args": [
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "nat"  },
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "nat"  },
                                     {  "prim": "nat"  }
                                   ]
                                }
                              ]
                           },
                           {  "prim": "nat"  }
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
                 {  "int": "3"  }
               ]
            },
            {  "prim": "CDR",
               "args": [
                 {  "int": "1"  }
               ]
            },
            {  "prim": "COMPARE"  },
            {  "prim": "LT"  },
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
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "CDR",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "PAIR"  },
                 {  "prim": "PUSH",
                    "args": [
                      {  "prim": "string"  },
                      {  "string": "calculateRemaining"  }
                    ]
                 },
                 {  "prim": "PAIR"  },
                 {  "prim": "FAILWITH"  }  ],
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
                 {  "int": "3"  }
               ]
            },
            {  "prim": "CDR",
               "args": [
                 {  "int": "1"  }
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
                 {  "int": "1"  }
               ]
            },
            {  "prim": "CDR",
               "args": [
                 {  "int": "1"  }
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
            {  "prim": "PAIR"  },
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
                 {  "int": "2"  }
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
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "nat"  },
                      {  "prim": "pair",
                         "args": [
                           {  "prim": "nat"  },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "nat"  },
                                {  "prim": "lambda",
                                   "args": [
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "nat"  },
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "nat"  },
                                               {  "prim": "nat"  }
                                             ]
                                          }
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
            {  "prim": "EXEC"  },
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
            {  "prim": "LE"  },
            {  "prim": "NOT"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "PUSH",
                       "args": [
                         {  "prim": "string"  },
                         {  "string": "fillLeft: unable to fill"  }
                       ]
                 },
                 {  "prim": "FAILWITH"  }  ],
                 [    ]
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
                 {  "prim": "nat"  },
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "nat"  },
                      {  "prim": "pair",
                         "args": [
                           {  "prim": "nat"  },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "nat"  },
                                {  "prim": "lambda",
                                   "args": [
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "nat"  },
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "nat"  },
                                               {  "prim": "nat"  }
                                             ]
                                          }
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
            {  "prim": "LE"  },
            {  "prim": "NOT"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "PUSH",
                       "args": [
                         {  "prim": "string"  },
                         {  "string": "fillRight: unable to fill"  }
                       ]
                 },
                 {  "prim": "FAILWITH"  }  ],
                 [    ]
               ]
            },
            {  "prim": "DUP"  },
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
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "nat"  },
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "nat"  },
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "nat"  },
                                                              {  "prim": "lambda",
                                                                 "args": [
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
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
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
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

                                                                   "%makeAsset"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "pair",
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
                                                         },
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "nat"  },
                                                              {  "prim": "lambda",
                                                                 "args": [
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {  "prim": "nat"  }
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
                                               {  "prim": "lambda",
                                                  "args": [
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "nat"  },
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "nat"  },
                                                              {  "prim": "nat"  }
                                                            ]
                                                         }
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
            },
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
            {  "prim": "EXEC"  },
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
            {  "prim": "CDR",
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
                      {  "int": "1"  }
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
                 {  "prim": "EXEC"  }  ],
                 [  {  "prim": "DIG",
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
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "CDR",
                    "args": [
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "PAIR"  },
                 {  "prim": "EXEC"  }  ]
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
            {  "prim": "DROP",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "DUG",
               "args": [
                 {  "int": "8"  }
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "8"  }
               ]
            }  ]
          ]
       },
       {  "prim": "LAMBDA",
          "args": [
            {  "prim": "pair",
               "args": [
                 {  "prim": "big_map",
                    "args": [
                      {  "prim": "bytes"  },
                      {  "prim": "nat"  }
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
                      },
                      {  "prim": "bytes"  }
                    ]
                 }
               ]
            },
            {  "prim": "nat"  },
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
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "nat"  },
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
            {  "prim": "MEM"  },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "nat"  },
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
            {  "prim": "CAR",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "COMPARE"  },
            {  "prim": "NEQ"  },
            {  "prim": "AND"  },
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
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "DUG",
                    "args": [
                      {  "int": "4"  }
                    ]
                 },
                 {  "prim": "GET"  },
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
                 }
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
            {  "prim": "EQ"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "PUSH",
                       "args": [
                         {  "prim": "nat"  },
                         {  "int": "1"  }
                       ]
                 },
                 {  "prim": "SWAP"  },
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
                 {  "prim": "IF",
                    "args": [
                      [  {  "prim": "PUSH",
                            "args": [
                              {  "prim": "nat"  },
                              {  "int": "2"  }
                            ]
                      },
                      {  "prim": "SWAP"  },
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
                                     {  "prim": "bytes"  }
                                   ]
                                }
                              ]
                           }
                         ]
                      },
                      {  "prim": "RIGHT",
                         "args": [
                           {  "prim": "unit"  }
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
                      {  "prim": "EQ"  },
                      {  "prim": "IF",
                         "args": [
                           [  {  "prim": "PUSH",
                                 "args": [
                                   {  "prim": "nat"  },
                                   {  "int": "1"  }
                                 ]
                           },
                           {  "prim": "SWAP"  },
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
                                          {  "prim": "bytes"  }
                                        ]
                                     }
                                   ]
                                }
                              ]
                           },
                           {  "prim": "RIGHT",
                              "args": [
                                {  "prim": "unit"  }
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
                           {  "prim": "IF",
                              "args": [
                                [  {  "prim": "PUSH",
                                      "args": [
                                        {  "prim": "nat"  },
                                        {  "int": "2"  }
                                      ]
                                },
                                {  "prim": "SWAP"  },
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
                                          {  "prim": "bytes"  }
                                        ]
                                     }
                                   ]
                                },
                                {  "prim": "RIGHT",
                                   "args": [
                                     {  "prim": "unit"  }
                                   ]
                                },
                                {  "prim": "RIGHT",
                                   "args": [
                                     {  "prim": "unit"  }
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
                                {  "prim": "EQ"  },
                                {  "prim": "IF",
                                   "args": [
                                     [  {  "prim": "PUSH",
                                           "args": [
                                             {  "prim": "nat"  },
                                             {  "int": "1"  }
                                           ]
                                     },
                                     {  "prim": "SWAP"  },
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
                                               {  "prim": "bytes"  }
                                             ]
                                          }
                                        ]
                                     },
                                     {  "prim": "RIGHT",
                                        "args": [
                                          {  "prim": "unit"  }
                                        ]
                                     },
                                     {  "prim": "RIGHT",
                                        "args": [
                                          {  "prim": "unit"  }
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
                                     {  "prim": "IF",
                                        "args": [
                                          [  {  "prim": "PUSH",
                                                "args": [
                                                  {  "prim": "nat"  },
                                                  {  "int": "2"  }
                                                ]
                                          },
                                          {  "prim": "SWAP"  },
                                          {  "prim": "DROP",
                                             "args": [
                                               {  "int": "1"  }
                                             ]
                                          }  ],
                                          [  {  "prim": "PUSH",
                                                "args": [
                                                  {  "prim": "nat"  },
                                                  {  "int": "0"  }
                                                ]
                                          },
                                          {  "prim": "SWAP"  },
                                          {  "prim": "DROP",
                                             "args": [
                                               {  "int": "1"  }
                                             ]
                                          }  ]
                                        ]
                                     }  ]
                                   ]
                                }  ]
                              ]
                           }  ]
                         ]
                      }  ]
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
                 {  "int": "2"  }
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
                           {  "prim": "bytes"  },
                           {  "prim": "address"  }
                         ]
                      }
                    ]
                 }
               ]
            },
            {  "prim": "or",
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
                 {  "prim": "operation"  }
               ]
            },
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
            {  "prim": "DUP"  },
            {  "prim": "LEFT",
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
            {  "prim": "CAR",
               "args": [
                 {  "int": "0"  }
               ]
            },
            {  "prim": "IF_LEFT",
               "args": [
                 [  {  "prim": "DROP",
                       "args": [
                         {  "int": "1"  }
                       ]
                 }  ],
                 [  {  "prim": "DUP"  },
                 {  "prim": "IF_LEFT",
                    "args": [
                      [  {  "prim": "DROP",
                            "args": [
                              {  "int": "1"  }
                            ]
                      }  ],
                      [  {  "prim": "DUP"  },
                      {  "prim": "IF_LEFT",
                         "args": [
                           [  {  "prim": "DIG",
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
                                [  {  "prim": "DIG",
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
                                {  "prim": "CDR",
                                   "args": [
                                     {  "int": "1"  }
                                   ]
                                },
                                {  "prim": "PUSH",
                                   "args": [
                                     {  "prim": "string"  },
                                     {  "string": "cannot unpack FA_2"  }
                                   ]
                                },
                                {  "prim": "PAIR"  },
                                {  "prim": "FAILWITH"  }  ],
                                [  {  "prim": "DUP"  },
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
                                     {  "int": "9"  }
                                   ]
                                },
                                {  "prim": "DUP"  },
                                {  "prim": "DUG",
                                   "args": [
                                     {  "int": "10"  }
                                   ]
                                },
                                {  "prim": "CONTRACT",
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
                                          {  "prim": "bytes"  }
                                        ]
                                     }
                                   ]
                                   ,
                                   "annots": [
                                     "%processRoyalities"
                                   ]
                                },
                                {  "prim": "IF_NONE",
                                   "args": [
                                     [  {  "prim": "PUSH",
                                           "args": [
                                             {  "prim": "string"  },
                                             {  "string": "processRoyalities not found"  }
                                           ]
                                     },
                                     {  "prim": "FAILWITH"  }  ],
                                     [    ]
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
                                {  "prim": "CONTRACT",
                                   "args": [
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "address"  },
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "nat"  },
                                                    {  "prim": "bytes"  }
                                                  ]
                                               }
                                             ]
                                          },
                                          {  "prim": "contract",
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
                                     "%getRoyalties"
                                   ]
                                },
                                {  "prim": "IF_NONE",
                                   "args": [
                                     [  {  "prim": "PUSH",
                                           "args": [
                                             {  "prim": "string"  },
                                             {  "string": "%getRoyalties not found"  }
                                           ]
                                     },
                                     {  "prim": "FAILWITH"  }  ],
                                     [    ]
                                   ]
                                },
                                {  "prim": "DUP"  },
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
                                     {  "int": "15"  }
                                   ]
                                },
                                {  "prim": "DUP"  },
                                {  "prim": "DUG",
                                   "args": [
                                     {  "int": "16"  }
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
                                {  "prim": "PAIR"  },
                                {  "prim": "TRANSFER_TOKENS"  },
                                {  "prim": "DUP"  },
                                {  "prim": "RIGHT",
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
                                     }
                                   ]
                                },
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
                                     {  "int": "6"  }
                                   ]
                                }  ]
                              ]
                           },
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
                                {  "prim": "UNPACK",
                                   "args": [
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "address"  },
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "nat"  },
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "string"  },
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "nat"  },
                                                         {  "prim": "pair",
                                                            "args": [
                                                              {  "prim": "list",
                                                                 "args": [
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "address"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                 ]
                                                              },
                                                              {  "prim": "pair",
                                                                 "args": [
                                                                   {
                                                                   "prim": "list",
                                                                   "args": [

                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "address"  },
                                                                   {  "prim": "nat"  }
                                                                   ]
                                                                   }
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "list",
                                                                   "args": [

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
                                {  "prim": "IF_NONE",
                                   "args": [
                                     [  {  "prim": "DIG",
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
                                     {  "prim": "PUSH",
                                        "args": [
                                          {  "prim": "string"  },
                                          {  "string": "cannot unpack FA_2_LAZY"  }
                                        ]
                                     },
                                     {  "prim": "PAIR"  },
                                     {  "prim": "FAILWITH"  }  ],
                                     [  {  "prim": "DUP"  },
                                     {  "prim": "CDR",
                                        "args": [
                                          {  "int": "1"  }
                                        ]
                                     },
                                     {  "prim": "CAR",
                                        "args": [
                                          {  "int": "4"  }
                                        ]
                                     },
                                     {  "prim": "LEFT",
                                        "args": [
                                          {  "prim": "operation"  }
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
                                }  ],
                                [  {  "prim": "DROP",
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
                 {  "int": "2"  }
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
                 {  "prim": "option",
                    "args": [
                      {  "prim": "timestamp"  }
                    ]
                 },
                 {  "prim": "nat"  }
               ]
            },
            {  "prim": "bool"  },
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
                         {  "prim": "True"  }
                       ]
                 }  ],
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
                 {  "prim": "DUP"  },
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
                      [  {  "prim": "NOW"  },
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
                      {  "prim": "LT"  }  ],
                      [  {  "prim": "NOW"  },
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
                      {  "prim": "GT"  }  ]
                    ]
                 },
                 {  "prim": "DIP",
                    "args": [
                      {  "int": "1"  },
                      [  {  "prim": "DROP",
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
                 {  "prim": "option",
                    "args": [
                      {  "prim": "signature"  }
                    ]
                 }
               ]
            },
            {  "prim": "bool"  },
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
            {  "prim": "DUP"  },
            {  "prim": "HASH_KEY"  },
            {  "prim": "IMPLICIT_ACCOUNT"  },
            {  "prim": "ADDRESS"  },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "nat"  },
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
            {  "prim": "CAR",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "COMPARE"  },
            {  "prim": "EQ"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "DUP"  },
                 {  "prim": "SOURCE"  },
                 {  "prim": "COMPARE"  },
                 {  "prim": "EQ"  },
                 {  "prim": "NOT"  },
                 {  "prim": "IF",
                    "args": [
                      [  {  "prim": "PUSH",
                            "args": [
                              {  "prim": "string"  },
                              {  "string": "maker is not tx sender"  }
                            ]
                      },
                      {  "prim": "FAILWITH"  }  ],
                      [    ]
                    ]
                 },
                 {  "prim": "PUSH",
                    "args": [
                      {  "prim": "bool"  },
                      {  "prim": "True"  }
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
                 }  ],
                 [  {  "prim": "DUP"  },
                 {  "prim": "SOURCE"  },
                 {  "prim": "COMPARE"  },
                 {  "prim": "NEQ"  },
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
                      {  "prim": "IF_NONE",
                         "args": [
                           [  {  "prim": "PUSH",
                                 "args": [
                                   {  "prim": "string"  },
                                   {  "string": "signature none"  }
                                 ]
                           },
                           {  "prim": "FAILWITH"  }  ],
                           [    ]
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
                      {  "prim": "PACK"  },
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
                      {  "prim": "CHECK_SIGNATURE"  },
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
                              {  "prim": "bool"  },
                              {  "prim": "True"  }
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
                      }  ]
                    ]
                 }  ]
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "2"  }
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
            {  "prim": "option",
               "args": [
                 {  "prim": "key"  }
               ]
            },
            {  "prim": "bool"  },
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
            {  "prim": "IF_NONE",
               "args": [
                 [  {  "prim": "PUSH",
                       "args": [
                         {  "prim": "bool"  },
                         {  "prim": "False"  }
                       ]
                 },
                 {  "prim": "SWAP"  },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
                    ]
                 }  ],
                 [  {  "prim": "SENDER"  },
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
                 {  "prim": "HASH_KEY"  },
                 {  "prim": "IMPLICIT_ACCOUNT"  },
                 {  "prim": "ADDRESS"  },
                 {  "prim": "COMPARE"  },
                 {  "prim": "EQ"  },
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
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "option",
                         "args": [
                           {  "prim": "signature"  }
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
                                     },
                                     {  "prim": "option",
                                        "args": [
                                          {  "prim": "signature"  }
                                        ]
                                     }
                                   ]
                                },
                                {  "prim": "bool"  }
                              ]
                           },
                           {  "prim": "lambda",
                              "args": [
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "option",
                                        "args": [
                                          {  "prim": "timestamp"  }
                                        ]
                                     },
                                     {  "prim": "nat"  }
                                   ]
                                },
                                {  "prim": "bool"  }
                              ]
                           }
                         ]
                      }
                    ]
                 }
               ]
            },
            {  "prim": "bool"  },
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
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "nat"  },
                 {  "int": "0"  }
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
            {  "prim": "CAR",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "EXEC"  },
            {  "prim": "NOT"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "PUSH",
                       "args": [
                         {  "prim": "string"  },
                         {  "string": "Order start validation failed"  }
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
                 {  "prim": "nat"  },
                 {  "int": "1"  }
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
            {  "prim": "CAR",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "EXEC"  },
            {  "prim": "NOT"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "PUSH",
                       "args": [
                         {  "prim": "string"  },
                         {  "string": "Order end validation failed"  }
                       ]
                 },
                 {  "prim": "FAILWITH"  }  ],
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
            {  "prim": "NOT"  },
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
                 {  "prim": "PACK"  },
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
                 {  "prim": "PAIR"  },
                 {  "prim": "PUSH",
                    "args": [
                      {  "prim": "string"  },
                      {  "string": "Bad signature"  }
                    ]
                 },
                 {  "prim": "PAIR"  },
                 {  "prim": "FAILWITH"  }  ],
                 [    ]
               ]
            },
            {  "prim": "PUSH",
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
                 }
               ]
            },
            {  "prim": "option",
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
            {  "prim": "KECCAK"  },
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
            {  "prim": "KECCAK"  },
            {  "prim": "DUP"  },
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
                 }  ],
                 [  {  "prim": "NONE",
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
                         }
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
                 }  ]
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "2"  }
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
            {  "prim": "bool"  },
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
            {  "prim": "IF_LEFT",
               "args": [
                 [  {  "prim": "PUSH",
                       "args": [
                         {  "prim": "bool"  },
                         {  "prim": "False"  }
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
                      [  {  "prim": "PUSH",
                            "args": [
                              {  "prim": "bool"  },
                              {  "prim": "False"  }
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
                           [  {  "prim": "PUSH",
                                 "args": [
                                   {  "prim": "bool"  },
                                   {  "prim": "False"  }
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
                                [  {  "prim": "PUSH",
                                      "args": [
                                        {  "prim": "bool"  },
                                        {  "prim": "False"  }
                                      ]
                                },
                                {  "prim": "SWAP"  },
                                {  "prim": "DROP",
                                   "args": [
                                     {  "int": "1"  }
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
                      {  "prim": "lambda",
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
                           {  "prim": "bool"  }
                         ]
                      }
                    ]
                 }
               ]
            },
            {  "prim": "bool"  },
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
            {  "prim": "IF_LEFT",
               "args": [
                 [  {  "prim": "NONE",
                       "args": [
                         {  "prim": "bytes"  }
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
                              {  "prim": "bytes"  }
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
                                   {  "prim": "bytes"  }
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
                                        {  "prim": "bytes"  }
                                      ]
                                },
                                {  "prim": "SWAP"  },
                                {  "prim": "DROP",
                                   "args": [
                                     {  "int": "1"  }
                                   ]
                                }  ],
                                [  {  "prim": "DUP"  },
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
            {  "prim": "IF_LEFT",
               "args": [
                 [  {  "prim": "NONE",
                       "args": [
                         {  "prim": "bytes"  }
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
                              {  "prim": "bytes"  }
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
                                   {  "prim": "bytes"  }
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
                                        {  "prim": "bytes"  }
                                      ]
                                },
                                {  "prim": "SWAP"  },
                                {  "prim": "DROP",
                                   "args": [
                                     {  "int": "1"  }
                                   ]
                                }  ],
                                [  {  "prim": "DUP"  },
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
            {  "prim": "COMPARE"  },
            {  "prim": "EQ"  },
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
            {  "prim": "EXEC"  },
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
            {  "prim": "EXEC"  },
            {  "prim": "AND"  },
            {  "prim": "AND"  },
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
                           {  "prim": "lambda",
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
                                     }
                                   ]
                                },
                                {  "prim": "option",
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
                                               {  "prim": "lambda",
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
                                                    },
                                                    {  "prim": "bool"  }
                                                  ]
                                               }
                                             ]
                                          }
                                        ]
                                     },
                                     {  "prim": "bool"  }
                                   ]
                                },
                                {  "prim": "lambda",
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
                                     {  "prim": "bool"  }
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
            {  "prim": "CAR",
               "args": [
                 {  "int": "0"  }
               ]
            },
            {  "prim": "DUP"  },
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
            {  "prim": "PAIR"  },
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
            {  "prim": "EQ"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "DIG",
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
                 {  "prim": "SOME"  },
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
                 }  ],
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
                           {  "prim": "bytes"  }
                         ]
                      }
                    ]
                 },
                 {  "prim": "RIGHT",
                    "args": [
                      {  "prim": "unit"  }
                    ]
                 },
                 {  "prim": "RIGHT",
                    "args": [
                      {  "prim": "unit"  }
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
                           {  "prim": "bytes"  }
                         ]
                      }
                    ]
                 },
                 {  "prim": "RIGHT",
                    "args": [
                      {  "prim": "unit"  }
                    ]
                 },
                 {  "prim": "RIGHT",
                    "args": [
                      {  "prim": "unit"  }
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
                 {  "prim": "COMPARE"  },
                 {  "prim": "EQ"  },
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
                                {  "prim": "bytes"  }
                              ]
                           }
                         ]
                      }
                    ]
                 },
                 {  "prim": "RIGHT",
                    "args": [
                      {  "prim": "unit"  }
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
                                {  "prim": "bytes"  }
                              ]
                           }
                         ]
                      }
                    ]
                 },
                 {  "prim": "RIGHT",
                    "args": [
                      {  "prim": "unit"  }
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
                 {  "prim": "COMPARE"  },
                 {  "prim": "EQ"  },
                 {  "prim": "OR"  },
                 {  "prim": "OR"  },
                 {  "prim": "IF",
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
                      }  ],
                      [  {  "prim": "NONE",
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
                              }
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
                      }  ]
                    ]
                 }  ]
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "3"  }
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
       {  "prim": "NIL",
          "args": [
            {  "prim": "operation"  }
          ]
       },
       {  "prim": "DIG",
          "args": [
            {  "int": "18"  }
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
            {  "prim": "SWAP"  }  ]
          ]
       },
       {  "prim": "IF_LEFT",
          "args": [
            [  {  "prim": "IF_LEFT",
                  "args": [
                    [  {  "prim": "IF_LEFT",
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
                            {  "prim": "DIG",
                               "args": [
                                 {  "int": "1"  }
                               ]
                            },
                            {  "prim": "PAIR"  }  ],
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
                            [  {  "prim": "DUP"  },
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
                            {  "prim": "SOURCE"  },
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
                                 {  "int": "6"  }
                               ]
                            },
                            {  "prim": "DUP"  },
                            {  "prim": "DUG",
                               "args": [
                                 {  "int": "7"  }
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
                            {  "prim": "CAR",
                               "args": [
                                 {  "int": "4"  }
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
                                         {  "string": "0 salt can't be used"  }
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
                            {  "prim": "NONE",
                               "args": [
                                 {  "prim": "nat"  }
                               ]
                            },
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
                            {  "prim": "EXEC"  },
                            {  "prim": "UPDATE"  },
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
                                 {  "int": "1"  }
                               ]
                            },
                            {  "prim": "DUP"  },
                            {  "prim": "DUG",
                               "args": [
                                 {  "int": "2"  }
                               ]
                            },
                            {  "prim": "MEM"  },
                            {  "prim": "IF",
                               "args": [
                                 [  {  "prim": "PUSH",
                                       "args": [
                                         {  "prim": "string"  },
                                         {  "string": "KeyExists"  }
                                       ]
                                 },
                                 {  "prim": "FAILWITH"  }  ],
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
                                 {  "prim": "PUSH",
                                    "args": [
                                      {  "prim": "bool"  },
                                      {  "prim": "True"  }
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
                                 {  "prim": "UPDATE"  },
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
                            {  "prim": "MEM"  },
                            {  "prim": "IF",
                               "args": [
                                 [  {  "prim": "PUSH",
                                       "args": [
                                         {  "prim": "string"  },
                                         {  "string": "KeyExists"  }
                                       ]
                                 },
                                 {  "prim": "FAILWITH"  }  ],
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
                                 }  ]
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
                            [  {  "prim": "UNPAIR"  },
                            {  "prim": "SWAP"  },
                            {  "prim": "UNPAIR"  },
                            {  "prim": "SWAP"  },
                            {  "prim": "UNPAIR"  },
                            {  "prim": "SWAP"  },
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
                            {  "prim": "SENDER"  },
                            {  "prim": "MEM"  },
                            {  "prim": "SELF"  },
                            {  "prim": "ADDRESS"  },
                            {  "prim": "SENDER"  },
                            {  "prim": "COMPARE"  },
                            {  "prim": "EQ"  },
                            {  "prim": "OR"  },
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
                            {  "prim": "DUP"  },
                            {  "prim": "DUG",
                               "args": [
                                 {  "int": "2"  }
                               ]
                            },
                            {  "prim": "IF_NONE",
                               "args": [
                                 [  {  "prim": "PUSH",
                                       "args": [
                                         {  "prim": "string"  },
                                         {  "string": "Invalid makeMatch"  }
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
                            {  "prim": "IF_NONE",
                               "args": [
                                 [  {  "prim": "PUSH",
                                       "args": [
                                         {  "prim": "string"  },
                                         {  "string": "Invalid takeMatch"  }
                                       ]
                                 },
                                 {  "prim": "FAILWITH"  }  ],
                                 [    ]
                               ]
                            },
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
                                 {  "int": "6"  }
                               ]
                            },
                            {  "prim": "DUP"  },
                            {  "prim": "DUG",
                               "args": [
                                 {  "int": "7"  }
                               ]
                            },
                            {  "prim": "EXEC"  },
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
                                 {  "int": "6"  }
                               ]
                            },
                            {  "prim": "DUP"  },
                            {  "prim": "DUG",
                               "args": [
                                 {  "int": "7"  }
                               ]
                            },
                            {  "prim": "EXEC"  },
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
                                 {  "int": "26"  }
                               ]
                            },
                            {  "prim": "DUP"  },
                            {  "prim": "DUG",
                               "args": [
                                 {  "int": "27"  }
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
                            {  "prim": "EXEC"  },
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
                                 {  "int": "33"  }
                               ]
                            },
                            {  "prim": "DUP"  },
                            {  "prim": "DUG",
                               "args": [
                                 {  "int": "34"  }
                               ]
                            },
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
                            {  "prim": "EXEC"  },
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
                            {  "prim": "CDR",
                               "args": [
                                 {  "int": "1"  }
                               ]
                            },
                            {  "prim": "COMPARE"  },
                            {  "prim": "GT"  },
                            {  "prim": "NOT"  },
                            {  "prim": "IF",
                               "args": [
                                 [  {  "prim": "PUSH",
                                       "args": [
                                         {  "prim": "string"  },
                                         {  "string": "nothing to fill"  }
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
                                 {  "int": "11"  }
                               ]
                            },
                            {  "prim": "DUP"  },
                            {  "prim": "DUG",
                               "args": [
                                 {  "int": "12"  }
                               ]
                            },
                            {  "prim": "CAR",
                               "args": [
                                 {  "int": "4"  }
                               ]
                            },
                            {  "prim": "COMPARE"  },
                            {  "prim": "NEQ"  },
                            {  "prim": "IF",
                               "args": [
                                 [  {  "prim": "DIG",
                                       "args": [
                                         {  "int": "14"  }
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
                                 {  "prim": "SOME"  },
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
                                 {  "prim": "UPDATE"  },
                                 {  "prim": "DUG",
                                    "args": [
                                      {  "int": "14"  }
                                    ]
                                 }  ],
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
                                 {  "int": "10"  }
                               ]
                            },
                            {  "prim": "DUP"  },
                            {  "prim": "DUG",
                               "args": [
                                 {  "int": "11"  }
                               ]
                            },
                            {  "prim": "CAR",
                               "args": [
                                 {  "int": "4"  }
                               ]
                            },
                            {  "prim": "COMPARE"  },
                            {  "prim": "NEQ"  },
                            {  "prim": "IF",
                               "args": [
                                 [  {  "prim": "DIG",
                                       "args": [
                                         {  "int": "14"  }
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
                                 {  "prim": "ADD"  },
                                 {  "prim": "SOME"  },
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
                                 {  "prim": "UPDATE"  },
                                 {  "prim": "DUG",
                                    "args": [
                                      {  "int": "14"  }
                                    ]
                                 }  ],
                                 [    ]
                               ]
                            },
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
                            {  "prim": "EXEC"  },
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
                            {  "prim": "PACK"  },
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
                                 {  "int": "2"  }
                               ]
                            },
                            {  "prim": "DUP"  },
                            {  "prim": "DUG",
                               "args": [
                                 {  "int": "3"  }
                               ]
                            },
                            {  "prim": "DUP"  },
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
                                 {  "prim": "LEFT",
                                    "args": [
                                      {  "prim": "operation"  }
                                    ]
                                 }  ],
                                 [  {  "prim": "DUP"  },
                                 {  "prim": "PUSH",
                                    "args": [
                                      {  "prim": "nat"  },
                                      {  "int": "1"  }
                                    ]
                                 },
                                 {  "prim": "COMPARE"  },
                                 {  "prim": "EQ"  },
                                 {  "prim": "IF",
                                    "args": [
                                      [  {  "prim": "DIG",
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
                                      {  "prim": "SELF"  },
                                      {  "prim": "ADDRESS"  },
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
                                      {  "prim": "EXEC"  }  ],
                                      [  {  "prim": "DIG",
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
                                      {  "prim": "SELF"  },
                                      {  "prim": "ADDRESS"  },
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
                                      {  "prim": "EXEC"  }  ]
                                    ]
                                 }  ]
                               ]
                            },
                            {  "prim": "DIP",
                               "args": [
                                 {  "int": "1"  },
                                 [  {  "prim": "DROP",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                 }  ]
                               ]
                            },
                            {  "prim": "DUP"  },
                            {  "prim": "IF_LEFT",
                               "args": [
                                 [  {  "prim": "DIG",
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
                                 {  "prim": "CONTRACT",
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
                                                     },
                                                     {  "prim": "bytes"  }
                                                   ]
                                                },
                                                {  "prim": "pair",
                                                   "args": [
                                                     {  "prim": "pair",
                                                        "args": [
                                                          {  "prim": "nat"  },
                                                          {  "prim": "nat"  }
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
                                                                    },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                    },
                                                                    {  "prim": "nat"  }
                                                                    ]
                                                                    },
                                                                    {
                                                                    "prim": "pair",
                                                                    "args": [

                                                                    {
                                                                    "prim": "option",
                                                                    "args": [

                                                                    {  "prim": "key"  }
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
                                                                    },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                    },
                                                                    {  "prim": "nat"  }
                                                                    ]
                                                                    },
                                                                    {
                                                                    "prim": "pair",
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
                                                          },
                                                          {  "prim": "pair",
                                                             "args": [
                                                               {  "prim": "pair",
                                                                  "args": [
                                                                    {
                                                                    "prim": "option",
                                                                    "args": [

                                                                    {  "prim": "key"  }
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
                                                                    },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                    },
                                                                    {  "prim": "nat"  }
                                                                    ]
                                                                    },
                                                                    {
                                                                    "prim": "pair",
                                                                    "args": [

                                                                    {
                                                                    "prim": "option",
                                                                    "args": [

                                                                    {  "prim": "key"  }
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
                                                                    },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                    },
                                                                    {  "prim": "nat"  }
                                                                    ]
                                                                    },
                                                                    {
                                                                    "prim": "pair",
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
                                                               },
                                                               {  "prim": "pair",
                                                                  "args": [
                                                                    {  "prim": "nat"  },
                                                                    {
                                                                    "prim": "list",
                                                                    "args": [

                                                                    {
                                                                    "prim": "pair",
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
                                 {  "prim": "TRANSFER_TOKENS"  },
                                 {  "prim": "CONS"  },
                                 {  "prim": "DIP",
                                    "args": [
                                      {  "int": "1"  },
                                      [  {  "prim": "DIG",
                                            "args": [
                                              {  "int": "22"  }
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
                                      {  "int": "22"  }
                                    ]
                                 },
                                 {  "prim": "DROP",
                                    "args": [
                                      {  "int": "1"  }
                                    ]
                                 }  ],
                                 [  {  "prim": "DIG",
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
                                              {  "int": "22"  }
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
                                      {  "int": "22"  }
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
                                 {  "int": "15"  }
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
                                 {  "int": "6"  }
                               ]
                            },
                            {  "prim": "DUP"  },
                            {  "prim": "DUG",
                               "args": [
                                 {  "int": "7"  }
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
                            {  "prim": "UNPACK",
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
                                           {  "prim": "pair",
                                              "args": [
                                                {  "prim": "pair",
                                                   "args": [
                                                     {  "prim": "nat"  },
                                                     {  "prim": "nat"  }
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
                                                                    {
                                                                    "prim": "option",
                                                                    "args": [

                                                                    {  "prim": "key"  }
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
                                                                    },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                    },
                                                                    {  "prim": "nat"  }
                                                                    ]
                                                                    },
                                                                    {
                                                                    "prim": "pair",
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
                                                                    },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                    },
                                                                    {  "prim": "nat"  }
                                                                    ]
                                                                    },
                                                                    {
                                                                    "prim": "pair",
                                                                    "args": [

                                                                    {
                                                                    "prim": "option",
                                                                    "args": [

                                                                    {  "prim": "key"  }
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
                                                                    },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                    },
                                                                    {  "prim": "nat"  }
                                                                    ]
                                                                    },
                                                                    {
                                                                    "prim": "pair",
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
                            {  "prim": "IF_NONE",
                               "args": [
                                 [  {  "prim": "DUP"  },
                                 {  "prim": "PUSH",
                                    "args": [
                                      {  "prim": "string"  },
                                      {  "string": "cannot unpack"  }
                                    ]
                                 },
                                 {  "prim": "PAIR"  },
                                 {  "prim": "FAILWITH"  }  ],
                                 [  {  "prim": "DUP"  },
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
                                 {  "prim": "CAR",
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
                                 {  "prim": "CAR",
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
                                 {  "prim": "CAR",
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
                                 {  "prim": "CDR",
                                    "args": [
                                      {  "int": "5"  }
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
                                 {  "prim": "CONTRACT",
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
                                                     },
                                                     {  "prim": "bytes"  }
                                                   ]
                                                },
                                                {  "prim": "pair",
                                                   "args": [
                                                     {  "prim": "pair",
                                                        "args": [
                                                          {  "prim": "nat"  },
                                                          {  "prim": "nat"  }
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
                                                                    },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                    },
                                                                    {  "prim": "nat"  }
                                                                    ]
                                                                    },
                                                                    {
                                                                    "prim": "pair",
                                                                    "args": [

                                                                    {
                                                                    "prim": "option",
                                                                    "args": [

                                                                    {  "prim": "key"  }
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
                                                                    },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                    },
                                                                    {  "prim": "nat"  }
                                                                    ]
                                                                    },
                                                                    {
                                                                    "prim": "pair",
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
                                                          },
                                                          {  "prim": "pair",
                                                             "args": [
                                                               {  "prim": "pair",
                                                                  "args": [
                                                                    {
                                                                    "prim": "option",
                                                                    "args": [

                                                                    {  "prim": "key"  }
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
                                                                    },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                    },
                                                                    {  "prim": "nat"  }
                                                                    ]
                                                                    },
                                                                    {
                                                                    "prim": "pair",
                                                                    "args": [

                                                                    {
                                                                    "prim": "option",
                                                                    "args": [

                                                                    {  "prim": "key"  }
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
                                                                    },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                    },
                                                                    {  "prim": "nat"  }
                                                                    ]
                                                                    },
                                                                    {
                                                                    "prim": "pair",
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
                                                               },
                                                               {  "prim": "pair",
                                                                  "args": [
                                                                    {  "prim": "nat"  },
                                                                    {
                                                                    "prim": "list",
                                                                    "args": [

                                                                    {
                                                                    "prim": "pair",
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
                                 {  "prim": "TRANSFER_TOKENS"  },
                                 {  "prim": "CONS"  },
                                 {  "prim": "DIP",
                                    "args": [
                                      {  "int": "1"  },
                                      [  {  "prim": "DIG",
                                            "args": [
                                              {  "int": "15"  }
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
                                      {  "int": "15"  }
                                    ]
                                 },
                                 {  "prim": "DROP",
                                    "args": [
                                      {  "int": "7"  }
                                    ]
                                 }  ]
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
                            {  "prim": "DIG",
                               "args": [
                                 {  "int": "1"  }
                               ]
                            },
                            {  "prim": "PAIR"  }  ]
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
                         {  "int": "15"  }
                       ]
                    },
                    {  "prim": "DUP"  },
                    {  "prim": "DUG",
                       "args": [
                         {  "int": "16"  }
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
                    {  "prim": "EXEC"  },
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
                         {  "int": "2"  }
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
                    {  "prim": "IF",
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
                         {  "prim": "CAR",
                            "args": [
                              {  "int": "0"  }
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
                                      {  "string": "leftOrder.taker verification failed"  }
                                    ]
                              },
                              {  "prim": "FAILWITH"  }  ],
                              [    ]
                            ]
                         }  ],
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
                    {  "prim": "CAR",
                       "args": [
                         {  "int": "2"  }
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
                    {  "prim": "IF",
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
                              {  "int": "2"  }
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
                                      {  "string": "rightOrder.taker verification failed"  }
                                    ]
                              },
                              {  "prim": "FAILWITH"  }  ],
                              [    ]
                            ]
                         }  ],
                         [    ]
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
                         {  "int": "3"  }
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
                         {  "int": "1"  }
                       ]
                    },
                    {  "prim": "CAR",
                       "args": [
                         {  "int": "0"  }
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
                         {  "int": "1"  }
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
                         {  "int": "3"  }
                       ]
                    },
                    {  "prim": "CAR",
                       "args": [
                         {  "int": "0"  }
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
                    {  "prim": "PACK"  },
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
                         [  {  "prim": "PUSH",
                               "args": [
                                 {  "prim": "bool"  },
                                 {  "prim": "True"  }
                               ]
                         }  ],
                         [  {  "prim": "PUSH",
                               "args": [
                                 {  "prim": "bool"  },
                                 {  "prim": "False"  }
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
                                 {  "prim": "bool"  },
                                 {  "prim": "True"  }
                               ]
                         }  ],
                         [  {  "prim": "PUSH",
                               "args": [
                                 {  "prim": "bool"  },
                                 {  "prim": "False"  }
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
                    {  "prim": "OR"  },
                    {  "prim": "IF",
                       "args": [
                         [  {  "prim": "DIG",
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
                         {  "prim": "GET"  },
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
                              {  "int": "1"  }
                            ]
                         },
                         {  "prim": "DUP"  },
                         {  "prim": "DUG",
                            "args": [
                              {  "int": "2"  }
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
                                                                 {  "prim": "option",
                                                                    "args": [

                                                                    {  "prim": "key"  }
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
                                                                    },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                    },
                                                                    {  "prim": "nat"  }
                                                                    ]
                                                                    },
                                                                    {
                                                                    "prim": "pair",
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

                                                                    {
                                                                    "prim": "option",
                                                                    "args": [

                                                                    {  "prim": "key"  }
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
                                                                    },
                                                                    {  "prim": "bytes"  }
                                                                    ]
                                                                    },
                                                                    {  "prim": "nat"  }
                                                                    ]
                                                                    },
                                                                    {
                                                                    "prim": "pair",
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
                                                       },
                                                       {  "prim": "pair",
                                                          "args": [
                                                            {  "prim": "option",
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
                                                                 }
                                                               ]
                                                            },
                                                            {  "prim": "option",
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
                              "%matchAssets"
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
                         {  "prim": "SELF"  },
                         {  "prim": "ADDRESS"  },
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
                                        {  "prim": "pair",
                                           "args": [
                                             {  "prim": "option",
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
                                                       },
                                                       {  "prim": "bytes"  }
                                                     ]
                                                  }
                                                ]
                                             },
                                             {  "prim": "option",
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
                                                       },
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
                            ,
                            "annots": [
                              "%matchAndTransfer"
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
                         {  "prim": "TRANSFER_TOKENS"  },
                         {  "prim": "CONS"  },
                         {  "prim": "DIP",
                            "args": [
                              {  "int": "1"  },
                              [  {  "prim": "DIG",
                                    "args": [
                                      {  "int": "16"  }
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
                              {  "int": "16"  }
                            ]
                         },
                         {  "prim": "DROP",
                            "args": [
                              {  "int": "1"  }
                            ]
                         }  ],
                         [  {  "prim": "DIG",
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
                         {  "prim": "SELF"  },
                         {  "prim": "ADDRESS"  },
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
                                        {  "prim": "pair",
                                           "args": [
                                             {  "prim": "option",
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
                                                       },
                                                       {  "prim": "bytes"  }
                                                     ]
                                                  }
                                                ]
                                             },
                                             {  "prim": "option",
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
                                                       },
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
                            ,
                            "annots": [
                              "%matchAndTransfer"
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
                         {  "prim": "TRANSFER_TOKENS"  },
                         {  "prim": "CONS"  },
                         {  "prim": "DIP",
                            "args": [
                              {  "int": "1"  },
                              [  {  "prim": "DIG",
                                    "args": [
                                      {  "int": "15"  }
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
                              {  "int": "15"  }
                            ]
                         }  ]
                       ]
                    },
                    {  "prim": "DROP",
                       "args": [
                         {  "int": "9"  }
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
                    {  "int": "17"  }
                  ]
            }  ]
          ]
       }  ]
     ]
  }  ]

export function validator_storage(exchangeV2: string, royaltiesContract: string) : any {
  return {  "prim": "Pair",
            "args": [
              {  "string": exchangeV2  },
              {  "prim": "Pair",
                 "args": [
                   {  "string": royaltiesContract  },
                   {  "prim": "Pair",
                      "args": [
                        [    ],
                        {  "prim": "Pair",
                           "args": [
                             [    ],
                             {  "prim": "Pair",
                                "args": [
                                  [    ],
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
  }

export async function deploy_validator(
  provider : Provider,
  exchange: string,
  royalties: string,
) : Promise<OperationResult> {
  const init = validator_storage(exchange, royalties)
  return provider.tezos.originate({init, code: validator_code})
}
