import { Provider, OperationResult } from "../common/base"

export const validator_code : any =
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
                              {  "prim": "address",
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
                                                  {  "prim": "unit",
                                                     "annots": [
                                                       "%XTZ"
                                                     ]
                                                  },
                                                  {  "prim": "or",
                                                     "args": [
                                                       {  "prim": "unit",
                                                          "annots": [
                                                            "%FA_1_2"
                                                          ]
                                                       },
                                                       {  "prim": "or",
                                                          "args": [
                                                            {  "prim": "int",
                                                               "annots": [
                                                                 "%FA_2"
                                                               ]
                                                            },
                                                            {  "prim": "or",
                                                               "args": [
                                                                 {  "prim": "int",
                                                                    "annots": [

                                                                    "%FA_2_LAZY"
                                                                    ]
                                                                 },
                                                                 {  "prim": "bytes",
                                                                    "annots": [

                                                                    "%OTHER"
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
                      {  "prim": "address",
                         "annots": [
                           "%setFill"
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
                                               {  "prim": "unit",
                                                  "annots": [
                                                    "%XTZ"
                                                  ]
                                               },
                                               {  "prim": "or",
                                                  "args": [
                                                    {  "prim": "unit",
                                                       "annots": [
                                                         "%FA_1_2"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "int",
                                                            "annots": [
                                                              "%FA_2"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "int",
                                                                 "annots": [
                                                                   "%FA_2_LAZY"
                                                                 ]
                                                              },
                                                              {  "prim": "bytes",
                                                                 "annots": [
                                                                   "%OTHER"
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
                                                         {  "prim": "unit",
                                                            "annots": [
                                                              "%XTZ"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "unit",
                                                                 "annots": [
                                                                   "%FA_1_2"
                                                                 ]
                                                              },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                           {  "prim": "or",
                              "args": [
                                {  "prim": "unit",
                                   "annots": [
                                     "%XTZ"
                                   ]
                                },
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "unit",
                                        "annots": [
                                          "%FA_1_2"
                                        ]
                                     },
                                     {  "prim": "or",
                                        "args": [
                                          {  "prim": "int",
                                             "annots": [
                                               "%FA_2"
                                             ]
                                          },
                                          {  "prim": "or",
                                             "args": [
                                               {  "prim": "int",
                                                  "annots": [
                                                    "%FA_2_LAZY"
                                                  ]
                                               },
                                               {  "prim": "bytes",
                                                  "annots": [
                                                    "%OTHER"
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
                                                    {  "prim": "unit",
                                                       "annots": [
                                                         "%XTZ"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "unit",
                                                            "annots": [
                                                              "%FA_1_2"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "int",
                                                                 "annots": [
                                                                   "%FA_2"
                                                                 ]
                                                              },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                                              {  "prim": "unit",
                                                                 "annots": [
                                                                   "%XTZ"
                                                                 ]
                                                              },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [

                                                                   "%FA_1_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                                         {  "prim": "unit",
                                                            "annots": [
                                                              "%XTZ"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "unit",
                                                                 "annots": [
                                                                   "%FA_1_2"
                                                                 ]
                                                              },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [
                                                                     "%XTZ"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [

                                                                   "%FA_1_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                                    {  "prim": "unit",
                                                       "annots": [
                                                         "%XTZ"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "unit",
                                                            "annots": [
                                                              "%FA_1_2"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "int",
                                                                 "annots": [
                                                                   "%FA_2"
                                                                 ]
                                                              },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                                    {  "prim": "unit",
                                                       "annots": [
                                                         "%XTZ"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "unit",
                                                            "annots": [
                                                              "%FA_1_2"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "int",
                                                                 "annots": [
                                                                   "%FA_2"
                                                                 ]
                                                              },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                               {  "prim": "unit",
                                                  "annots": [
                                                    "%XTZ"
                                                  ]
                                               },
                                               {  "prim": "or",
                                                  "args": [
                                                    {  "prim": "unit",
                                                       "annots": [
                                                         "%FA_1_2"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "int",
                                                            "annots": [
                                                              "%FA_2"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "int",
                                                                 "annots": [
                                                                   "%FA_2_LAZY"
                                                                 ]
                                                              },
                                                              {  "prim": "bytes",
                                                                 "annots": [
                                                                   "%OTHER"
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
                                                         {  "prim": "unit",
                                                            "annots": [
                                                              "%XTZ"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "unit",
                                                                 "annots": [
                                                                   "%FA_1_2"
                                                                 ]
                                                              },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                                         {  "prim": "unit",
                                                            "annots": [
                                                              "%XTZ"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "unit",
                                                                 "annots": [
                                                                   "%FA_1_2"
                                                                 ]
                                                              },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [
                                                                     "%XTZ"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [

                                                                   "%FA_1_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                    {  "prim": "bytes"  },
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
                                             {  "prim": "unit",
                                                "annots": [
                                                  "%XTZ"
                                                ]
                                             },
                                             {  "prim": "or",
                                                "args": [
                                                  {  "prim": "unit",
                                                     "annots": [
                                                       "%FA_1_2"
                                                     ]
                                                  },
                                                  {  "prim": "or",
                                                     "args": [
                                                       {  "prim": "int",
                                                          "annots": [
                                                            "%FA_2"
                                                          ]
                                                       },
                                                       {  "prim": "or",
                                                          "args": [
                                                            {  "prim": "int",
                                                               "annots": [
                                                                 "%FA_2_LAZY"
                                                               ]
                                                            },
                                                            {  "prim": "bytes",
                                                               "annots": [
                                                                 "%OTHER"
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
                                                       {  "prim": "unit",
                                                          "annots": [
                                                            "%XTZ"
                                                          ]
                                                       },
                                                       {  "prim": "or",
                                                          "args": [
                                                            {  "prim": "unit",
                                                               "annots": [
                                                                 "%FA_1_2"
                                                               ]
                                                            },
                                                            {  "prim": "or",
                                                               "args": [
                                                                 {  "prim": "int",
                                                                    "annots": [
                                                                      "%FA_2"
                                                                    ]
                                                                 },
                                                                 {  "prim": "or",
                                                                    "args": [

                                                                    {
                                                                    "prim": "int",
                                                                    "annots": [

                                                                    "%FA_2_LAZY"
                                                                    ]
                                                                    },
                                                                    {
                                                                    "prim": "bytes",
                                                                    "annots": [

                                                                    "%OTHER"
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
                    }
                  ]
               },
               {  "prim": "bytes"  },
               [  {  "prim": "UNPAIR",
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
               {  "prim": "PUSH",
                  "args": [
                    {  "prim": "string"  },
                    {  "string": "V2"  }
                  ]
               },
               {  "prim": "PACK"  },
               {  "prim": "KECCAK"  },
               {  "prim": "DUP",
                  "args": [
                    {  "int": "4"  }
                  ]
               },
               {  "prim": "CDR"  },
               {  "prim": "CDR"  },
               {  "prim": "CDR"  },
               {  "prim": "CDR"  },
               {  "prim": "CDR"  },
               {  "prim": "CDR"  },
               {  "prim": "CDR"  },
               {  "prim": "CAR"  },
               {  "prim": "COMPARE"  },
               {  "prim": "EQ"  },
               {  "prim": "IF",
                  "args": [
                    [  {  "prim": "NIL",
                          "args": [
                            {  "prim": "bytes"  }
                          ]
                    },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "4"  }
                       ]
                    },
                    {  "prim": "CDR"  },
                    {  "prim": "CDR"  },
                    {  "prim": "CDR"  },
                    {  "prim": "CDR"  },
                    {  "prim": "CDR"  },
                    {  "prim": "CDR"  },
                    {  "prim": "CDR"  },
                    {  "prim": "CDR"  },
                    {  "prim": "PACK"  },
                    {  "prim": "CONS"  },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "4"  }
                       ]
                    },
                    {  "prim": "CDR"  },
                    {  "prim": "CDR"  },
                    {  "prim": "CDR"  },
                    {  "prim": "CDR"  },
                    {  "prim": "CAR"  },
                    {  "prim": "PACK"  },
                    {  "prim": "CONS"  },
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
                    {  "prim": "PACK"  },
                    {  "prim": "KECCAK"  },
                    {  "prim": "CONS"  },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "4"  }
                       ]
                    },
                    {  "prim": "CDR"  },
                    {  "prim": "CAR"  },
                    {  "prim": "CAR"  },
                    {  "prim": "PACK"  },
                    {  "prim": "KECCAK"  },
                    {  "prim": "CONS"  },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "4"  }
                       ]
                    },
                    {  "prim": "CAR"  },
                    {  "prim": "PACK"  },
                    {  "prim": "CONS"  },
                    {  "prim": "CONCAT"  },
                    {  "prim": "KECCAK"  },
                    {  "prim": "SWAP"  },
                    {  "prim": "DROP",
                       "args": [
                         {  "int": "1"  }
                       ]
                    }  ],
                    [  {  "prim": "NIL",
                          "args": [
                            {  "prim": "bytes"  }
                          ]
                    },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "4"  }
                       ]
                    },
                    {  "prim": "CDR"  },
                    {  "prim": "CDR"  },
                    {  "prim": "CDR"  },
                    {  "prim": "CDR"  },
                    {  "prim": "CAR"  },
                    {  "prim": "PACK"  },
                    {  "prim": "CONS"  },
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
                    {  "prim": "PACK"  },
                    {  "prim": "KECCAK"  },
                    {  "prim": "CONS"  },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "4"  }
                       ]
                    },
                    {  "prim": "CDR"  },
                    {  "prim": "CAR"  },
                    {  "prim": "CAR"  },
                    {  "prim": "PACK"  },
                    {  "prim": "KECCAK"  },
                    {  "prim": "CONS"  },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "4"  }
                       ]
                    },
                    {  "prim": "CAR"  },
                    {  "prim": "PACK"  },
                    {  "prim": "CONS"  },
                    {  "prim": "CONCAT"  },
                    {  "prim": "KECCAK"  },
                    {  "prim": "SWAP"  },
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
            [  {  "prim": "UNPAIR",
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
            {  "prim": "DUP",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "MUL"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "DUP",
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
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "COMPARE"  },
                 {  "prim": "NEQ"  },
                 {  "prim": "IF",
                    "args": [
                      [  {  "prim": "DUP",
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
                      {  "prim": "DUP",
                         "args": [
                           {  "int": "3"  }
                         ]
                      },
                      {  "prim": "CDR"  },
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
                 {  "prim": "CAR"  },
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
                                          {  "prim": "unit",
                                             "annots": [
                                               "%XTZ"
                                             ]
                                          },
                                          {  "prim": "or",
                                             "args": [
                                               {  "prim": "unit",
                                                  "annots": [
                                                    "%FA_1_2"
                                                  ]
                                               },
                                               {  "prim": "or",
                                                  "args": [
                                                    {  "prim": "int",
                                                       "annots": [
                                                         "%FA_2"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "int",
                                                            "annots": [
                                                              "%FA_2_LAZY"
                                                            ]
                                                         },
                                                         {  "prim": "bytes",
                                                            "annots": [
                                                              "%OTHER"
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
                                                    {  "prim": "unit",
                                                       "annots": [
                                                         "%XTZ"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "unit",
                                                            "annots": [
                                                              "%FA_1_2"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "int",
                                                                 "annots": [
                                                                   "%FA_2"
                                                                 ]
                                                              },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                           {  "prim": "bool"  },
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
            },
            {  "prim": "pair",
               "args": [
                 {  "prim": "nat"  },
                 {  "prim": "nat"  }
               ]
            },
            [  {  "prim": "UNPAIR",
                  "args": [
                    {  "int": "4"  }
                  ]
            },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "unit"  },
                 {  "prim": "Unit"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "NOT"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "DUP",
                       "args": [
                         {  "int": "3"  }
                       ]
                 },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CAR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "COMPARE"  },
                 {  "prim": "LT"  },
                 {  "prim": "IF",
                    "args": [
                      [  {  "prim": "DUP",
                            "args": [
                              {  "int": "3"  }
                            ]
                      },
                      {  "prim": "DUP",
                         "args": [
                           {  "int": "3"  }
                         ]
                      },
                      {  "prim": "CDR"  },
                      {  "prim": "CDR"  },
                      {  "prim": "CDR"  },
                      {  "prim": "CAR"  },
                      {  "prim": "CDR"  },
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
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CAR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "PAIR"  },
                 {  "prim": "UNPAIR"  },
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
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "6"  }
                    ]
                 },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "5"  }
                    ]
                 },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CAR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "PAIR"  },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "5"  }
                    ]
                 },
                 {  "prim": "CDR"  },
                 {  "prim": "CAR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "PAIR"  },
                 {  "prim": "EXEC"  },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "DUP",
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
                 }  ],
                 [  {  "prim": "DUP",
                       "args": [
                         {  "int": "3"  }
                       ]
                 },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "CDR"  },
                 {  "prim": "CAR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "COMPARE"  },
                 {  "prim": "LT"  },
                 {  "prim": "IF",
                    "args": [
                      [  {  "prim": "DUP",
                            "args": [
                              {  "int": "3"  }
                            ]
                      },
                      {  "prim": "DUP",
                         "args": [
                           {  "int": "3"  }
                         ]
                      },
                      {  "prim": "CDR"  },
                      {  "prim": "CAR"  },
                      {  "prim": "CDR"  },
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
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "CDR"  },
                 {  "prim": "CAR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "PAIR"  },
                 {  "prim": "UNPAIR"  },
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
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "6"  }
                    ]
                 },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "5"  }
                    ]
                 },
                 {  "prim": "CDR"  },
                 {  "prim": "CAR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "PAIR"  },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "5"  }
                    ]
                 },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CAR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "PAIR"  },
                 {  "prim": "EXEC"  },
                 {  "prim": "DUP"  },
                 {  "prim": "DUP",
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
            [  {  "prim": "UNPAIR",
                  "args": [
                    {  "int": "5"  }
                  ]
            },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "unit"  },
                 {  "prim": "Unit"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "EXEC"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DUP",
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
            {  "prim": "DUP",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "DUP",
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
            [  {  "prim": "UNPAIR",
                  "args": [
                    {  "int": "5"  }
                  ]
            },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "unit"  },
                 {  "prim": "Unit"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "7"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "EXEC"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "DUP",
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
            {  "prim": "DUP",
               "args": [
                 {  "int": "7"  }
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
                                          {  "prim": "unit",
                                             "annots": [
                                               "%XTZ"
                                             ]
                                          },
                                          {  "prim": "or",
                                             "args": [
                                               {  "prim": "unit",
                                                  "annots": [
                                                    "%FA_1_2"
                                                  ]
                                               },
                                               {  "prim": "or",
                                                  "args": [
                                                    {  "prim": "int",
                                                       "annots": [
                                                         "%FA_2"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "int",
                                                            "annots": [
                                                              "%FA_2_LAZY"
                                                            ]
                                                         },
                                                         {  "prim": "bytes",
                                                            "annots": [
                                                              "%OTHER"
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
                                                    {  "prim": "unit",
                                                       "annots": [
                                                         "%XTZ"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "unit",
                                                            "annots": [
                                                              "%FA_1_2"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "int",
                                                                 "annots": [
                                                                   "%FA_2"
                                                                 ]
                                                              },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                               {  "prim": "unit",
                                                  "annots": [
                                                    "%XTZ"
                                                  ]
                                               },
                                               {  "prim": "or",
                                                  "args": [
                                                    {  "prim": "unit",
                                                       "annots": [
                                                         "%FA_1_2"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "int",
                                                            "annots": [
                                                              "%FA_2"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "int",
                                                                 "annots": [
                                                                   "%FA_2_LAZY"
                                                                 ]
                                                              },
                                                              {  "prim": "bytes",
                                                                 "annots": [
                                                                   "%OTHER"
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
                                                         {  "prim": "unit",
                                                            "annots": [
                                                              "%XTZ"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "unit",
                                                                 "annots": [
                                                                   "%FA_1_2"
                                                                 ]
                                                              },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                     {  "prim": "bool"  },
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "bool"  },
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
                                                              {  "prim": "nat"  },
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
                                                                     "%maker"
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

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [
                                                                     "%XTZ"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [

                                                                   "%FA_1_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [
                                                                     "%XTZ"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [

                                                                   "%FA_1_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "bool"  },
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
                                     }
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
            [  {  "prim": "UNPAIR",
                  "args": [
                    {  "int": "10"  }
                  ]
            },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "unit"  },
                 {  "prim": "Unit"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "10"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "12"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "8"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "EXEC"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "11"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "13"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "10"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "8"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "EXEC"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "CAR"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "CDR"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "CAR"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "CDR"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "COMPARE"  },
            {  "prim": "GT"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "DUP",
                       "args": [
                         {  "int": "15"  }
                       ]
                 },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "18"  }
                    ]
                 },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "11"  }
                    ]
                 },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CAR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "PAIR"  },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "11"  }
                    ]
                 },
                 {  "prim": "CDR"  },
                 {  "prim": "CAR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "PAIR"  },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "5"  }
                    ]
                 },
                 {  "prim": "PAIR"  },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "6"  }
                    ]
                 },
                 {  "prim": "PAIR"  },
                 {  "prim": "EXEC"  }  ],
                 [  {  "prim": "DUP",
                       "args": [
                         {  "int": "14"  }
                       ]
                 },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "18"  }
                    ]
                 },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "PAIR"  },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "4"  }
                    ]
                 },
                 {  "prim": "PAIR"  },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "10"  }
                    ]
                 },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CAR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "PAIR"  },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "10"  }
                    ]
                 },
                 {  "prim": "CDR"  },
                 {  "prim": "CAR"  },
                 {  "prim": "CDR"  },
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
                 {  "int": "10"  }
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "10"  }
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
                                               {  "prim": "unit",
                                                  "annots": [
                                                    "%XTZ"
                                                  ]
                                               },
                                               {  "prim": "or",
                                                  "args": [
                                                    {  "prim": "unit",
                                                       "annots": [
                                                         "%FA_1_2"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "int",
                                                            "annots": [
                                                              "%FA_2"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "int",
                                                                 "annots": [
                                                                   "%FA_2_LAZY"
                                                                 ]
                                                              },
                                                              {  "prim": "bytes",
                                                                 "annots": [
                                                                   "%OTHER"
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
                                                         {  "prim": "unit",
                                                            "annots": [
                                                              "%XTZ"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "unit",
                                                                 "annots": [
                                                                   "%FA_1_2"
                                                                 ]
                                                              },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
            [  {  "prim": "UNPAIR",
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
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "nat"  },
                 {  "int": "0"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "VIEW",
               "args": [
                 {  "string": "contains"  },
                 {  "prim": "bool"  }
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
                 [    ]
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "nat"  },
                 {  "int": "0"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "7"  }
               ]
            },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CAR"  },
            {  "prim": "COMPARE"  },
            {  "prim": "NEQ"  },
            {  "prim": "AND"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "DUP",
                       "args": [
                         {  "int": "4"  }
                       ]
                 },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "7"  }
                    ]
                 },
                 {  "prim": "VIEW",
                    "args": [
                      {  "string": "get"  },
                      {  "prim": "nat"  }
                    ]
                 },
                 {  "prim": "IF_NONE",
                    "args": [
                      [  {  "prim": "PUSH",
                            "args": [
                              {  "prim": "string"  },
                              {  "string": "invalid"  }
                            ]
                      },
                      {  "prim": "FAILWITH"  }  ],
                      [  {  "prim": "DUP"  },
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
                 }  ],
                 [    ]
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "2"  }
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
                 {  "prim": "or",
                    "args": [
                      {  "prim": "unit",
                         "annots": [
                           "%XTZ"
                         ]
                      },
                      {  "prim": "or",
                         "args": [
                           {  "prim": "unit",
                              "annots": [
                                "%FA_1_2"
                              ]
                           },
                           {  "prim": "or",
                              "args": [
                                {  "prim": "int",
                                   "annots": [
                                     "%FA_2"
                                   ]
                                },
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "int",
                                        "annots": [
                                          "%FA_2_LAZY"
                                        ]
                                     },
                                     {  "prim": "bytes",
                                        "annots": [
                                          "%OTHER"
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
                 {  "prim": "or",
                    "args": [
                      {  "prim": "unit",
                         "annots": [
                           "%XTZ"
                         ]
                      },
                      {  "prim": "or",
                         "args": [
                           {  "prim": "unit",
                              "annots": [
                                "%FA_1_2"
                              ]
                           },
                           {  "prim": "or",
                              "args": [
                                {  "prim": "int",
                                   "annots": [
                                     "%FA_2"
                                   ]
                                },
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "int",
                                        "annots": [
                                          "%FA_2_LAZY"
                                        ]
                                     },
                                     {  "prim": "bytes",
                                        "annots": [
                                          "%OTHER"
                                        ]
                                     }
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
            {  "prim": "int"  },
            [  {  "prim": "UNPAIR",
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
                           {  "prim": "int"  },
                           {  "prim": "or",
                              "args": [
                                {  "prim": "int"  },
                                {  "prim": "bytes"  }
                              ]
                           }
                         ]
                      }
                    ]
                 }
               ]
            },
            {  "prim": "DUP",
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
                         {  "prim": "int"  },
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
                                {  "prim": "int"  },
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "int"  },
                                     {  "prim": "bytes"  }
                                   ]
                                }
                              ]
                           }
                         ]
                      }
                    ]
                 },
                 {  "prim": "DUP",
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
                              {  "prim": "int"  },
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
                                {  "prim": "int"  },
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "int"  },
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
                      {  "prim": "DUP",
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
                                   {  "prim": "int"  },
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
                                     {  "prim": "int"  },
                                     {  "prim": "or",
                                        "args": [
                                          {  "prim": "int"  },
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
                           {  "prim": "DUP",
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
                                        {  "prim": "int"  },
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
                                        {  "prim": "int"  },
                                        {  "int": "0"  }
                                      ]
                                },
                                {  "prim": "LEFT",
                                   "args": [
                                     {  "prim": "or",
                                        "args": [
                                          {  "prim": "int"  },
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
                                {  "prim": "DUP",
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
                                             {  "prim": "int"  },
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
                                             {  "prim": "int"  },
                                             {  "int": "0"  }
                                           ]
                                     },
                                     {  "prim": "LEFT",
                                        "args": [
                                          {  "prim": "or",
                                             "args": [
                                               {  "prim": "int"  },
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
                                     {  "prim": "DUP",
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
                                                  {  "prim": "int"  },
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
                                                  {  "prim": "int"  },
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
                                {  "prim": "unit",
                                   "annots": [
                                     "%XTZ"
                                   ]
                                },
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "unit",
                                        "annots": [
                                          "%FA_1_2"
                                        ]
                                     },
                                     {  "prim": "or",
                                        "args": [
                                          {  "prim": "int",
                                             "annots": [
                                               "%FA_2"
                                             ]
                                          },
                                          {  "prim": "or",
                                             "args": [
                                               {  "prim": "int",
                                                  "annots": [
                                                    "%FA_2_LAZY"
                                                  ]
                                               },
                                               {  "prim": "bytes",
                                                  "annots": [
                                                    "%OTHER"
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
            [  {  "prim": "UNPAIR",
                  "args": [
                    {  "int": "4"  }
                  ]
            },
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
            {  "prim": "DUP",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "CAR"  },
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
                           [  {  "prim": "DUP",
                                 "args": [
                                   {  "int": "8"  }
                                 ]
                           },
                           {  "prim": "CDR"  },
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
                                [  {  "prim": "DUP",
                                      "args": [
                                        {  "int": "8"  }
                                      ]
                                },
                                {  "prim": "CDR"  },
                                {  "prim": "PUSH",
                                   "args": [
                                     {  "prim": "string"  },
                                     {  "string": "cannot unpack FA_2"  }
                                   ]
                                },
                                {  "prim": "PAIR"  },
                                {  "prim": "FAILWITH"  }  ],
                                [  {  "prim": "DUP"  },
                                {  "prim": "CAR"  },
                                {  "prim": "DUP",
                                   "args": [
                                     {  "int": "2"  }
                                   ]
                                },
                                {  "prim": "CDR"  },
                                {  "prim": "DUP",
                                   "args": [
                                     {  "int": "10"  }
                                   ]
                                },
                                {  "prim": "DUP",
                                   "args": [
                                     {  "int": "2"  }
                                   ]
                                },
                                {  "prim": "DUP",
                                   "args": [
                                     {  "int": "4"  }
                                   ]
                                },
                                {  "prim": "PAIR"  },
                                {  "prim": "VIEW",
                                   "args": [
                                     {  "string": "getRoyalties"  },
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
                                     }
                                   ]
                                },
                                {  "prim": "IF_NONE",
                                   "args": [
                                     [  {  "prim": "PUSH",
                                           "args": [
                                             {  "prim": "string"  },
                                             {  "string": "cannot get royalies from contract"  }
                                           ]
                                     },
                                     {  "prim": "FAILWITH"  }  ],
                                     [  {  "prim": "DUP"  },
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
                                     {  "prim": "DROP",
                                        "args": [
                                          {  "int": "1"  }
                                        ]
                                     }  ]
                                   ]
                                },
                                {  "prim": "DROP",
                                   "args": [
                                     {  "int": "3"  }
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
                                [  {  "prim": "DUP",
                                      "args": [
                                        {  "int": "9"  }
                                      ]
                                },
                                {  "prim": "CDR"  },
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
                                     [  {  "prim": "DUP",
                                           "args": [
                                             {  "int": "9"  }
                                           ]
                                     },
                                     {  "prim": "CDR"  },
                                     {  "prim": "PUSH",
                                        "args": [
                                          {  "prim": "string"  },
                                          {  "string": "cannot unpack FA_2_LAZY"  }
                                        ]
                                     },
                                     {  "prim": "PAIR"  },
                                     {  "prim": "FAILWITH"  }  ],
                                     [  {  "prim": "DUP"  },
                                     {  "prim": "CDR"  },
                                     {  "prim": "CDR"  },
                                     {  "prim": "CDR"  },
                                     {  "prim": "CDR"  },
                                     {  "prim": "CDR"  },
                                     {  "prim": "CAR"  },
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
                 {  "prim": "address"  },
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
                                               {  "prim": "unit",
                                                  "annots": [
                                                    "%XTZ"
                                                  ]
                                               },
                                               {  "prim": "or",
                                                  "args": [
                                                    {  "prim": "unit",
                                                       "annots": [
                                                         "%FA_1_2"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "int",
                                                            "annots": [
                                                              "%FA_2"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "int",
                                                                 "annots": [
                                                                   "%FA_2_LAZY"
                                                                 ]
                                                              },
                                                              {  "prim": "bytes",
                                                                 "annots": [
                                                                   "%OTHER"
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
                                                         {  "prim": "unit",
                                                            "annots": [
                                                              "%XTZ"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "unit",
                                                                 "annots": [
                                                                   "%FA_1_2"
                                                                 ]
                                                              },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                                    {  "prim": "unit",
                                                       "annots": [
                                                         "%XTZ"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "unit",
                                                            "annots": [
                                                              "%FA_1_2"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "int",
                                                                 "annots": [
                                                                   "%FA_2"
                                                                 ]
                                                              },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                                              {  "prim": "unit",
                                                                 "annots": [
                                                                   "%XTZ"
                                                                 ]
                                                              },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [

                                                                   "%FA_1_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                           },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "bytes"  },
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "bytes"  },
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
                                                    "%v2_payouts"
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
                                                         "%v2_originFees"
                                                       ]
                                                    },
                                                    {  "prim": "bool",
                                                       "annots": [
                                                         "%v2_isMakeFill"
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
                                                         "%v2_payouts"
                                                       ]
                                                    },
                                                    {  "prim": "pair",
                                                       "args": [
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
                                                              "%v2_originFees"
                                                            ]
                                                         },
                                                         {  "prim": "bool",
                                                            "annots": [
                                                              "%v2_isMakeFill"
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
                                                                   "prim": "option",
                                                                   "args": [

                                                                   {  "prim": "key"  }
                                                                   ]
                                                                   ,
                                                                   "annots": [
                                                                     "%maker"
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

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [
                                                                     "%XTZ"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [

                                                                   "%FA_1_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [
                                                                     "%XTZ"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [

                                                                   "%FA_1_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                                                     "%maker"
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

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [
                                                                     "%XTZ"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [

                                                                   "%FA_1_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [
                                                                     "%XTZ"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [

                                                                   "%FA_1_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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

                                                                   {  "prim": "bool"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "bool"  },
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
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%fr_makeValue"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%fr_takeValue"
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
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%fr_makeValue"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%fr_takeValue"
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
                                                                   "prim": "option",
                                                                   "args": [

                                                                   {  "prim": "key"  }
                                                                   ]
                                                                   ,
                                                                   "annots": [
                                                                     "%maker"
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

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [
                                                                     "%XTZ"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [

                                                                   "%FA_1_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [
                                                                     "%XTZ"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [

                                                                   "%FA_1_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "bool"  },
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
                                                                   }
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
                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%fr_makeValue"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
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
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {
                                                                   "prim": "nat",
                                                                   "annots": [

                                                                   "%fr_makeValue"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "nat",
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
                                                                   "prim": "option",
                                                                   "args": [

                                                                   {  "prim": "key"  }
                                                                   ]
                                                                   ,
                                                                   "annots": [
                                                                     "%maker"
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

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [
                                                                     "%XTZ"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [

                                                                   "%FA_1_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [
                                                                     "%XTZ"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [

                                                                   "%FA_1_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "nat"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

                                                                   {  "prim": "bool"  },
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
                                                                   {  "prim": "nat"  }
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

                                                                   {  "prim": "address"  },
                                                                   {
                                                                   "prim": "pair",
                                                                   "args": [

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
                                                                     "%maker"
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

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [
                                                                     "%XTZ"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [

                                                                   "%FA_1_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [
                                                                     "%XTZ"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [

                                                                   "%FA_1_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                                                   {  "prim": "bytes"  }
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
                                     }
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
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "option",
                         "args": [
                           {  "prim": "nat"  }
                         ]
                      },
                      {  "prim": "option",
                         "args": [
                           {  "prim": "nat"  }
                         ]
                      }
                    ]
                 }
               ]
            },
            [  {  "prim": "UNPAIR",
                  "args": [
                    {  "int": "13"  }
                  ]
            },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "unit"  },
                 {  "prim": "Unit"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "14"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "EXEC"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "15"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "8"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "7"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "EXEC"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "11"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "16"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "16"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "15"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "14"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "12"  }
               ]
            },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "PAIR"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "11"  }
               ]
            },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "PAIR"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "8"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "7"  }
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
            {  "prim": "DUP",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "CDR"  },
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
            {  "prim": "NONE",
               "args": [
                 {  "prim": "nat"  }
               ]
            },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "nat"  },
                 {  "int": "0"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "8"  }
               ]
            },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CAR"  },
            {  "prim": "COMPARE"  },
            {  "prim": "NEQ"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "DUP",
                       "args": [
                         {  "int": "11"  }
                       ]
                 },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "IF",
                    "args": [
                      [  {  "prim": "DUP",
                            "args": [
                              {  "int": "2"  }
                            ]
                      },
                      {  "prim": "CAR"  },
                      {  "prim": "DUP",
                         "args": [
                           {  "int": "5"  }
                         ]
                      },
                      {  "prim": "ADD"  },
                      {  "prim": "SOME"  },
                      {  "prim": "SWAP"  },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ],
                      [  {  "prim": "DUP",
                            "args": [
                              {  "int": "2"  }
                            ]
                      },
                      {  "prim": "CDR"  },
                      {  "prim": "DUP",
                         "args": [
                           {  "int": "5"  }
                         ]
                      },
                      {  "prim": "ADD"  },
                      {  "prim": "SOME"  },
                      {  "prim": "SWAP"  },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ]
                    ]
                 }  ],
                 [    ]
               ]
            },
            {  "prim": "NONE",
               "args": [
                 {  "prim": "nat"  }
               ]
            },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "nat"  },
                 {  "int": "0"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "10"  }
               ]
            },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CAR"  },
            {  "prim": "COMPARE"  },
            {  "prim": "NEQ"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "DUP",
                       "args": [
                         {  "int": "13"  }
                       ]
                 },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "IF",
                    "args": [
                      [  {  "prim": "DUP",
                            "args": [
                              {  "int": "3"  }
                            ]
                      },
                      {  "prim": "CDR"  },
                      {  "prim": "DUP",
                         "args": [
                           {  "int": "5"  }
                         ]
                      },
                      {  "prim": "ADD"  },
                      {  "prim": "SOME"  },
                      {  "prim": "SWAP"  },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ],
                      [  {  "prim": "DUP",
                            "args": [
                              {  "int": "3"  }
                            ]
                      },
                      {  "prim": "CAR"  },
                      {  "prim": "DUP",
                         "args": [
                           {  "int": "5"  }
                         ]
                      },
                      {  "prim": "ADD"  },
                      {  "prim": "SOME"  },
                      {  "prim": "SWAP"  },
                      {  "prim": "DROP",
                         "args": [
                           {  "int": "1"  }
                         ]
                      }  ]
                    ]
                 }  ],
                 [    ]
               ]
            },
            {  "prim": "DUP"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "DUP",
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
                 {  "int": "5"  }
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
                           "%v2_payouts"
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
                                "%v2_originFees"
                              ]
                           },
                           {  "prim": "bool",
                              "annots": [
                                "%v2_isMakeFill"
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
                      "%v2_payouts"
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
                           "%v2_originFees"
                         ]
                      },
                      {  "prim": "bool",
                         "annots": [
                           "%v2_isMakeFill"
                         ]
                      }
                    ]
                 }
               ]
            },
            [  {  "prim": "UNPAIR",
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
            {  "prim": "DUP",
               "args": [
                 {  "int": "3"  }
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
            {  "prim": "DUP",
               "args": [
                 {  "int": "5"  }
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
                                                    {  "prim": "unit",
                                                       "annots": [
                                                         "%XTZ"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "unit",
                                                            "annots": [
                                                              "%FA_1_2"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "int",
                                                                 "annots": [
                                                                   "%FA_2"
                                                                 ]
                                                              },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                                              {  "prim": "unit",
                                                                 "annots": [
                                                                   "%XTZ"
                                                                 ]
                                                              },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [

                                                                   "%FA_1_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                               "%v2_payouts"
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
                                                    "%v2_originFees"
                                                  ]
                                               },
                                               {  "prim": "bool",
                                                  "annots": [
                                                    "%v2_isMakeFill"
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
                                          "%v2_payouts"
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
                                               "%v2_originFees"
                                             ]
                                          },
                                          {  "prim": "bool",
                                             "annots": [
                                               "%v2_isMakeFill"
                                             ]
                                          }
                                        ]
                                     }
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
                      "%v2_payouts"
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
                           "%v2_originFees"
                         ]
                      },
                      {  "prim": "bool",
                         "annots": [
                           "%v2_isMakeFill"
                         ]
                      }
                    ]
                 }
               ]
            },
            [  {  "prim": "UNPAIR",
                  "args": [
                    {  "int": "4"  }
                  ]
            },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "unit"  },
                 {  "prim": "Unit"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "CAR"  },
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
            {  "prim": "DUP",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CAR"  },
            {  "prim": "COMPARE"  },
            {  "prim": "EQ"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "DUP",
                       "args": [
                         {  "int": "5"  }
                       ]
                 },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
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
                      [  {  "prim": "PUSH",
                            "args": [
                              {  "prim": "bool"  },
                              {  "prim": "False"  }
                            ]
                      },
                      {  "prim": "DUP",
                         "args": [
                           {  "int": "2"  }
                         ]
                      },
                      {  "prim": "CDR"  },
                      {  "prim": "PAIR"  },
                      {  "prim": "DUP",
                         "args": [
                           {  "int": "2"  }
                         ]
                      },
                      {  "prim": "CAR"  },
                      {  "prim": "PAIR"  },
                      {  "prim": "PUSH",
                         "args": [
                           {  "prim": "nat"  },
                           {  "int": "0"  }
                         ]
                      },
                      {  "prim": "DUP",
                         "args": [
                           {  "int": "3"  }
                         ]
                      },
                      {  "prim": "CAR"  },
                      {  "prim": "SIZE"  },
                      {  "prim": "COMPARE"  },
                      {  "prim": "EQ"  },
                      {  "prim": "IF",
                         "args": [
                           [  {  "prim": "DUP",
                                 "args": [
                                   {  "int": "8"  }
                                 ]
                           },
                           {  "prim": "DUP",
                              "args": [
                                {  "int": "2"  }
                              ]
                           },
                           {  "prim": "DUP",
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
                         {  "prim": "string"  },
                         {  "string": "V2"  }
                       ]
                 },
                 {  "prim": "PACK"  },
                 {  "prim": "KECCAK"  },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "6"  }
                    ]
                 },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CDR"  },
                 {  "prim": "CAR"  },
                 {  "prim": "COMPARE"  },
                 {  "prim": "EQ"  },
                 {  "prim": "IF",
                    "args": [
                      [  {  "prim": "DUP",
                            "args": [
                              {  "int": "5"  }
                            ]
                      },
                      {  "prim": "CDR"  },
                      {  "prim": "CDR"  },
                      {  "prim": "CDR"  },
                      {  "prim": "CDR"  },
                      {  "prim": "CDR"  },
                      {  "prim": "CDR"  },
                      {  "prim": "CDR"  },
                      {  "prim": "CDR"  },
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
                                     {  "prim": "bool"  }
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
                                   {  "string": "unable to unpack DataV2"  }
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
                           {  "prim": "DUP",
                              "args": [
                                {  "int": "3"  }
                              ]
                           },
                           {  "prim": "CAR"  },
                           {  "prim": "SIZE"  },
                           {  "prim": "COMPARE"  },
                           {  "prim": "EQ"  },
                           {  "prim": "IF",
                              "args": [
                                [  {  "prim": "DUP",
                                      "args": [
                                        {  "int": "8"  }
                                      ]
                                },
                                {  "prim": "DUP",
                                   "args": [
                                     {  "int": "3"  }
                                   ]
                                },
                                {  "prim": "DUP",
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
                      {  "prim": "DUP",
                         "args": [
                           {  "int": "6"  }
                         ]
                      },
                      {  "prim": "CDR"  },
                      {  "prim": "CDR"  },
                      {  "prim": "CDR"  },
                      {  "prim": "CDR"  },
                      {  "prim": "CDR"  },
                      {  "prim": "CDR"  },
                      {  "prim": "CDR"  },
                      {  "prim": "CAR"  },
                      {  "prim": "COMPARE"  },
                      {  "prim": "EQ"  },
                      {  "prim": "IF",
                         "args": [
                           [  {  "prim": "PUSH",
                                 "args": [
                                   {  "prim": "bool"  },
                                   {  "prim": "False"  }
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
                           {  "prim": "DUP",
                              "args": [
                                {  "int": "7"  }
                              ]
                           },
                           {  "prim": "DUP",
                              "args": [
                                {  "int": "2"  }
                              ]
                           },
                           {  "prim": "DUP",
                              "args": [
                                {  "int": "4"  }
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
                           },
                           {  "prim": "DROP",
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
                 {  "prim": "int"  }
               ]
            },
            {  "prim": "bool"  },
            [  {  "prim": "UNPAIR",
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
            {  "prim": "DUP",
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
                 [  {  "prim": "DUP",
                       "args": [
                         {  "int": "4"  }
                       ]
                 },
                 {  "prim": "DUP"  },
                 {  "prim": "PUSH",
                    "args": [
                      {  "prim": "int"  },
                      {  "int": "0"  }
                    ]
                 },
                 {  "prim": "COMPARE"  },
                 {  "prim": "EQ"  },
                 {  "prim": "IF",
                    "args": [
                      [  {  "prim": "NOW"  },
                      {  "prim": "DUP",
                         "args": [
                           {  "int": "3"  }
                         ]
                      },
                      {  "prim": "COMPARE"  },
                      {  "prim": "LT"  }  ],
                      [  {  "prim": "NOW"  },
                      {  "prim": "DUP",
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
                                          {  "prim": "unit",
                                             "annots": [
                                               "%XTZ"
                                             ]
                                          },
                                          {  "prim": "or",
                                             "args": [
                                               {  "prim": "unit",
                                                  "annots": [
                                                    "%FA_1_2"
                                                  ]
                                               },
                                               {  "prim": "or",
                                                  "args": [
                                                    {  "prim": "int",
                                                       "annots": [
                                                         "%FA_2"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "int",
                                                            "annots": [
                                                              "%FA_2_LAZY"
                                                            ]
                                                         },
                                                         {  "prim": "bytes",
                                                            "annots": [
                                                              "%OTHER"
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
                                                    {  "prim": "unit",
                                                       "annots": [
                                                         "%XTZ"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "unit",
                                                            "annots": [
                                                              "%FA_1_2"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "int",
                                                                 "annots": [
                                                                   "%FA_2"
                                                                 ]
                                                              },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
            [  {  "prim": "UNPAIR",
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
            {  "prim": "DUP",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "CAR"  },
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
            {  "prim": "DUP",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CAR"  },
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
                      [  {  "prim": "DUP",
                            "args": [
                              {  "int": "5"  }
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
                      {  "prim": "DUP",
                         "args": [
                           {  "int": "5"  }
                         ]
                      },
                      {  "prim": "PACK"  },
                      {  "prim": "DUP",
                         "args": [
                           {  "int": "2"  }
                         ]
                      },
                      {  "prim": "DUP",
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
            {  "prim": "DUP",
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
                 {  "prim": "DUP",
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
                                          {  "prim": "unit",
                                             "annots": [
                                               "%XTZ"
                                             ]
                                          },
                                          {  "prim": "or",
                                             "args": [
                                               {  "prim": "unit",
                                                  "annots": [
                                                    "%FA_1_2"
                                                  ]
                                               },
                                               {  "prim": "or",
                                                  "args": [
                                                    {  "prim": "int",
                                                       "annots": [
                                                         "%FA_2"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "int",
                                                            "annots": [
                                                              "%FA_2_LAZY"
                                                            ]
                                                         },
                                                         {  "prim": "bytes",
                                                            "annots": [
                                                              "%OTHER"
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
                                                    {  "prim": "unit",
                                                       "annots": [
                                                         "%XTZ"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "unit",
                                                            "annots": [
                                                              "%FA_1_2"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "int",
                                                                 "annots": [
                                                                   "%FA_2"
                                                                 ]
                                                              },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                                              {  "prim": "unit",
                                                                 "annots": [
                                                                   "%XTZ"
                                                                 ]
                                                              },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [

                                                                   "%FA_1_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [
                                                                     "%XTZ"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "unit",
                                                                   "annots": [

                                                                   "%FA_1_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                     {  "prim": "int"  }
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
            [  {  "prim": "UNPAIR",
                  "args": [
                    {  "int": "4"  }
                  ]
            },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "unit"  },
                 {  "prim": "Unit"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "int"  },
                 {  "int": "0"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CAR"  },
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
            {  "prim": "DUP",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "int"  },
                 {  "int": "1"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CDR"  },
            {  "prim": "CAR"  },
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
            {  "prim": "DUP",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "PAIR"  },
            {  "prim": "EXEC"  },
            {  "prim": "NOT"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "DUP",
                       "args": [
                         {  "int": "3"  }
                       ]
                 },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "PACK"  },
                 {  "prim": "PAIR"  },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "CAR"  },
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
                           {  "prim": "unit",
                              "annots": [
                                "%XTZ"
                              ]
                           },
                           {  "prim": "or",
                              "args": [
                                {  "prim": "unit",
                                   "annots": [
                                     "%FA_1_2"
                                   ]
                                },
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "int",
                                        "annots": [
                                          "%FA_2"
                                        ]
                                     },
                                     {  "prim": "or",
                                        "args": [
                                          {  "prim": "int",
                                             "annots": [
                                               "%FA_2_LAZY"
                                             ]
                                          },
                                          {  "prim": "bytes",
                                             "annots": [
                                               "%OTHER"
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
                           {  "prim": "unit",
                              "annots": [
                                "%XTZ"
                              ]
                           },
                           {  "prim": "or",
                              "args": [
                                {  "prim": "unit",
                                   "annots": [
                                     "%FA_1_2"
                                   ]
                                },
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "int",
                                        "annots": [
                                          "%FA_2"
                                        ]
                                     },
                                     {  "prim": "or",
                                        "args": [
                                          {  "prim": "int",
                                             "annots": [
                                               "%FA_2_LAZY"
                                             ]
                                          },
                                          {  "prim": "bytes",
                                             "annots": [
                                               "%OTHER"
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
                           {  "prim": "unit",
                              "annots": [
                                "%XTZ"
                              ]
                           },
                           {  "prim": "or",
                              "args": [
                                {  "prim": "unit",
                                   "annots": [
                                     "%FA_1_2"
                                   ]
                                },
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "int",
                                        "annots": [
                                          "%FA_2"
                                        ]
                                     },
                                     {  "prim": "or",
                                        "args": [
                                          {  "prim": "int",
                                             "annots": [
                                               "%FA_2_LAZY"
                                             ]
                                          },
                                          {  "prim": "bytes",
                                             "annots": [
                                               "%OTHER"
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
            [  {  "prim": "UNPAIR",
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
            {  "prim": "DUP",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "CDR"  },
            {  "prim": "KECCAK"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "CDR"  },
            {  "prim": "KECCAK"  },
            {  "prim": "DUP"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "3"  }
               ]
            },
            {  "prim": "COMPARE"  },
            {  "prim": "EQ"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "DUP",
                       "args": [
                         {  "int": "4"  }
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
                                             {  "prim": "int"  },
                                             {  "prim": "or",
                                                "args": [
                                                  {  "prim": "int"  },
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
                 {  "prim": "unit",
                    "annots": [
                      "%XTZ"
                    ]
                 },
                 {  "prim": "or",
                    "args": [
                      {  "prim": "unit",
                         "annots": [
                           "%FA_1_2"
                         ]
                      },
                      {  "prim": "or",
                         "args": [
                           {  "prim": "int",
                              "annots": [
                                "%FA_2"
                              ]
                           },
                           {  "prim": "or",
                              "args": [
                                {  "prim": "int",
                                   "annots": [
                                     "%FA_2_LAZY"
                                   ]
                                },
                                {  "prim": "bytes",
                                   "annots": [
                                     "%OTHER"
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
            {  "prim": "bool"  },
            [  {  "prim": "PUSH",
                  "args": [
                    {  "prim": "unit"  },
                    {  "prim": "Unit"  }
                  ]
            },
            {  "prim": "DUP",
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
                      {  "prim": "unit",
                         "annots": [
                           "%XTZ"
                         ]
                      },
                      {  "prim": "or",
                         "args": [
                           {  "prim": "unit",
                              "annots": [
                                "%FA_1_2"
                              ]
                           },
                           {  "prim": "or",
                              "args": [
                                {  "prim": "int",
                                   "annots": [
                                     "%FA_2"
                                   ]
                                },
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "int",
                                        "annots": [
                                          "%FA_2_LAZY"
                                        ]
                                     },
                                     {  "prim": "bytes",
                                        "annots": [
                                          "%OTHER"
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
                      {  "prim": "or",
                         "args": [
                           {  "prim": "unit",
                              "annots": [
                                "%XTZ"
                              ]
                           },
                           {  "prim": "or",
                              "args": [
                                {  "prim": "unit",
                                   "annots": [
                                     "%FA_1_2"
                                   ]
                                },
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "int",
                                        "annots": [
                                          "%FA_2"
                                        ]
                                     },
                                     {  "prim": "or",
                                        "args": [
                                          {  "prim": "int",
                                             "annots": [
                                               "%FA_2_LAZY"
                                             ]
                                          },
                                          {  "prim": "bytes",
                                             "annots": [
                                               "%OTHER"
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
                           {  "prim": "or",
                              "args": [
                                {  "prim": "unit",
                                   "annots": [
                                     "%XTZ"
                                   ]
                                },
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "unit",
                                        "annots": [
                                          "%FA_1_2"
                                        ]
                                     },
                                     {  "prim": "or",
                                        "args": [
                                          {  "prim": "int",
                                             "annots": [
                                               "%FA_2"
                                             ]
                                          },
                                          {  "prim": "or",
                                             "args": [
                                               {  "prim": "int",
                                                  "annots": [
                                                    "%FA_2_LAZY"
                                                  ]
                                               },
                                               {  "prim": "bytes",
                                                  "annots": [
                                                    "%OTHER"
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
                           {  "prim": "bool"  }
                         ]
                      }
                    ]
                 }
               ]
            },
            {  "prim": "bool"  },
            [  {  "prim": "UNPAIR",
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
            {  "prim": "DUP",
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
            {  "prim": "DUP",
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
            {  "prim": "COMPARE"  },
            {  "prim": "EQ"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "EXEC"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "6"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "5"  }
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
                           {  "prim": "unit",
                              "annots": [
                                "%XTZ"
                              ]
                           },
                           {  "prim": "or",
                              "args": [
                                {  "prim": "unit",
                                   "annots": [
                                     "%FA_1_2"
                                   ]
                                },
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "int",
                                        "annots": [
                                          "%FA_2"
                                        ]
                                     },
                                     {  "prim": "or",
                                        "args": [
                                          {  "prim": "int",
                                             "annots": [
                                               "%FA_2_LAZY"
                                             ]
                                          },
                                          {  "prim": "bytes",
                                             "annots": [
                                               "%OTHER"
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
                                {  "prim": "unit",
                                   "annots": [
                                     "%XTZ"
                                   ]
                                },
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "unit",
                                        "annots": [
                                          "%FA_1_2"
                                        ]
                                     },
                                     {  "prim": "or",
                                        "args": [
                                          {  "prim": "int",
                                             "annots": [
                                               "%FA_2"
                                             ]
                                          },
                                          {  "prim": "or",
                                             "args": [
                                               {  "prim": "int",
                                                  "annots": [
                                                    "%FA_2_LAZY"
                                                  ]
                                               },
                                               {  "prim": "bytes",
                                                  "annots": [
                                                    "%OTHER"
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
                                               {  "prim": "unit",
                                                  "annots": [
                                                    "%XTZ"
                                                  ]
                                               },
                                               {  "prim": "or",
                                                  "args": [
                                                    {  "prim": "unit",
                                                       "annots": [
                                                         "%FA_1_2"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "int",
                                                            "annots": [
                                                              "%FA_2"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "int",
                                                                 "annots": [
                                                                   "%FA_2_LAZY"
                                                                 ]
                                                              },
                                                              {  "prim": "bytes",
                                                                 "annots": [
                                                                   "%OTHER"
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
                                               {  "prim": "unit",
                                                  "annots": [
                                                    "%XTZ"
                                                  ]
                                               },
                                               {  "prim": "or",
                                                  "args": [
                                                    {  "prim": "unit",
                                                       "annots": [
                                                         "%FA_1_2"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "int",
                                                            "annots": [
                                                              "%FA_2"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "int",
                                                                 "annots": [
                                                                   "%FA_2_LAZY"
                                                                 ]
                                                              },
                                                              {  "prim": "bytes",
                                                                 "annots": [
                                                                   "%OTHER"
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
                                               {  "prim": "unit",
                                                  "annots": [
                                                    "%XTZ"
                                                  ]
                                               },
                                               {  "prim": "or",
                                                  "args": [
                                                    {  "prim": "unit",
                                                       "annots": [
                                                         "%FA_1_2"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "int",
                                                            "annots": [
                                                              "%FA_2"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "int",
                                                                 "annots": [
                                                                   "%FA_2_LAZY"
                                                                 ]
                                                              },
                                                              {  "prim": "bytes",
                                                                 "annots": [
                                                                   "%OTHER"
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
                                               {  "prim": "unit",
                                                  "annots": [
                                                    "%XTZ"
                                                  ]
                                               },
                                               {  "prim": "or",
                                                  "args": [
                                                    {  "prim": "unit",
                                                       "annots": [
                                                         "%FA_1_2"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "int",
                                                            "annots": [
                                                              "%FA_2"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "int",
                                                                 "annots": [
                                                                   "%FA_2_LAZY"
                                                                 ]
                                                              },
                                                              {  "prim": "bytes",
                                                                 "annots": [
                                                                   "%OTHER"
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
                                               {  "prim": "or",
                                                  "args": [
                                                    {  "prim": "unit",
                                                       "annots": [
                                                         "%XTZ"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "unit",
                                                            "annots": [
                                                              "%FA_1_2"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "int",
                                                                 "annots": [
                                                                   "%FA_2"
                                                                 ]
                                                              },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "unit",
                                                            "annots": [
                                                              "%XTZ"
                                                            ]
                                                         },
                                                         {  "prim": "or",
                                                            "args": [
                                                              {  "prim": "unit",
                                                                 "annots": [
                                                                   "%FA_1_2"
                                                                 ]
                                                              },
                                                              {  "prim": "or",
                                                                 "args": [
                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [
                                                                     "%FA_2"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "or",
                                                                   "args": [

                                                                   {
                                                                   "prim": "int",
                                                                   "annots": [

                                                                   "%FA_2_LAZY"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "bytes",
                                                                   "annots": [
                                                                     "%OTHER"
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
                                          {  "prim": "unit",
                                             "annots": [
                                               "%XTZ"
                                             ]
                                          },
                                          {  "prim": "or",
                                             "args": [
                                               {  "prim": "unit",
                                                  "annots": [
                                                    "%FA_1_2"
                                                  ]
                                               },
                                               {  "prim": "or",
                                                  "args": [
                                                    {  "prim": "int",
                                                       "annots": [
                                                         "%FA_2"
                                                       ]
                                                    },
                                                    {  "prim": "or",
                                                       "args": [
                                                         {  "prim": "int",
                                                            "annots": [
                                                              "%FA_2_LAZY"
                                                            ]
                                                         },
                                                         {  "prim": "bytes",
                                                            "annots": [
                                                              "%OTHER"
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
                           {  "prim": "unit",
                              "annots": [
                                "%XTZ"
                              ]
                           },
                           {  "prim": "or",
                              "args": [
                                {  "prim": "unit",
                                   "annots": [
                                     "%FA_1_2"
                                   ]
                                },
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "int",
                                        "annots": [
                                          "%FA_2"
                                        ]
                                     },
                                     {  "prim": "or",
                                        "args": [
                                          {  "prim": "int",
                                             "annots": [
                                               "%FA_2_LAZY"
                                             ]
                                          },
                                          {  "prim": "bytes",
                                             "annots": [
                                               "%OTHER"
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
            [  {  "prim": "UNPAIR",
                  "args": [
                    {  "int": "5"  }
                  ]
            },
            {  "prim": "PUSH",
               "args": [
                 {  "prim": "unit"  },
                 {  "prim": "Unit"  }
               ]
            },
            {  "prim": "DUP",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "CAR"  },
            {  "prim": "DUP",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "CAR"  },
            {  "prim": "DUP"  },
            {  "prim": "DUP",
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
                           {  "prim": "int"  },
                           {  "prim": "or",
                              "args": [
                                {  "prim": "int"  },
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
                           {  "prim": "int"  },
                           {  "prim": "or",
                              "args": [
                                {  "prim": "int"  },
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
            {  "prim": "DUP",
               "args": [
                 {  "int": "2"  }
               ]
            },
            {  "prim": "COMPARE"  },
            {  "prim": "EQ"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "DUP",
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
                 [  {  "prim": "DUP",
                       "args": [
                         {  "int": "8"  }
                       ]
                 },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "10"  }
                    ]
                 },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "4"  }
                    ]
                 },
                 {  "prim": "PAIR"  },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "5"  }
                    ]
                 },
                 {  "prim": "PAIR"  },
                 {  "prim": "EXEC"  },
                 {  "prim": "PUSH",
                    "args": [
                      {  "prim": "int"  },
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "LEFT",
                    "args": [
                      {  "prim": "or",
                         "args": [
                           {  "prim": "int"  },
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
                      {  "prim": "int"  },
                      {  "int": "1"  }
                    ]
                 },
                 {  "prim": "LEFT",
                    "args": [
                      {  "prim": "or",
                         "args": [
                           {  "prim": "int"  },
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
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "COMPARE"  },
                 {  "prim": "EQ"  },
                 {  "prim": "PUSH",
                    "args": [
                      {  "prim": "int"  },
                      {  "int": "0"  }
                    ]
                 },
                 {  "prim": "LEFT",
                    "args": [
                      {  "prim": "or",
                         "args": [
                           {  "prim": "int"  },
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
                      {  "prim": "int"  },
                      {  "int": "0"  }
                    ]
                 },
                 {  "prim": "LEFT",
                    "args": [
                      {  "prim": "or",
                         "args": [
                           {  "prim": "int"  },
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
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "4"  }
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
                           {  "prim": "int"  },
                           {  "prim": "or",
                              "args": [
                                {  "prim": "int"  },
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
                           {  "prim": "int"  },
                           {  "prim": "or",
                              "args": [
                                {  "prim": "int"  },
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
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "5"  }
                    ]
                 },
                 {  "prim": "COMPARE"  },
                 {  "prim": "EQ"  },
                 {  "prim": "OR"  },
                 {  "prim": "OR"  },
                 {  "prim": "OR"  },
                 {  "prim": "IF",
                    "args": [
                      [  {  "prim": "DUP",
                            "args": [
                              {  "int": "7"  }
                            ]
                      },
                      {  "prim": "DUP",
                         "args": [
                           {  "int": "7"  }
                         ]
                      },
                      {  "prim": "DUP",
                         "args": [
                           {  "int": "7"  }
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
                                                  {  "prim": "int"  },
                                                  {  "prim": "or",
                                                     "args": [
                                                       {  "prim": "int"  },
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
            {  "int": "21"  }
          ]
       },
       {  "prim": "UNPAIR"  },
       {  "prim": "DIP",
          "args": [
            {  "int": "1"  },
            [  {  "prim": "UNPAIR",
                  "args": [
                    {  "int": "7"  }
                  ]
            }  ]
          ]
       },
       {  "prim": "IF_LEFT",
          "args": [
            [  {  "prim": "IF_LEFT",
                  "args": [
                    [  {  "prim": "IF_LEFT",
                          "args": [
                            [  {  "prim": "DUP",
                                  "args": [
                                    {  "int": "3"  }
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
                            },
                            {  "prim": "PAIR",
                               "args": [
                                 {  "int": "7"  }
                               ]
                            },
                            {  "prim": "DIG",
                               "args": [
                                 {  "int": "1"  }
                               ]
                            },
                            {  "prim": "PAIR"  }  ],
                            [  {  "prim": "DUP",
                                  "args": [
                                    {  "int": "3"  }
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
                                 {  "int": "7"  }
                               ]
                            },
                            {  "prim": "DUP",
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
                                 {  "int": "7"  }
                               ]
                            },
                            {  "prim": "DROP",
                               "args": [
                                 {  "int": "1"  }
                               ]
                            },
                            {  "prim": "PAIR",
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
                    }  ],
                    [  {  "prim": "IF_LEFT",
                          "args": [
                            [  {  "prim": "DUP",
                                  "args": [
                                    {  "int": "2"  }
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
                            {  "prim": "PAIR",
                               "args": [
                                 {  "int": "7"  }
                               ]
                            },
                            {  "prim": "DIG",
                               "args": [
                                 {  "int": "1"  }
                               ]
                            },
                            {  "prim": "PAIR"  }  ],
                            [  {  "prim": "DUP"  },
                            {  "prim": "CAR"  },
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
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "3"  }
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
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "2"  }
                               ]
                            },
                            {  "prim": "CDR"  },
                            {  "prim": "CDR"  },
                            {  "prim": "CDR"  },
                            {  "prim": "CDR"  },
                            {  "prim": "CAR"  },
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
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "9"  }
                               ]
                            },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "6"  }
                               ]
                            },
                            {  "prim": "CONTRACT",
                               "args": [
                                 {  "prim": "bytes"  }
                               ]
                               ,
                               "annots": [
                                 "%remove"
                               ]
                            },
                            {  "prim": "IF_NONE",
                               "args": [
                                 [  {  "prim": "PUSH",
                                       "args": [
                                         {  "prim": "string"  },
                                         {  "string": "remove"  }
                                       ]
                                 },
                                 {  "prim": "PUSH",
                                    "args": [
                                      {  "prim": "string"  },
                                      {  "string": "EntryNotFound"  }
                                    ]
                                 },
                                 {  "prim": "PAIR"  },
                                 {  "prim": "FAILWITH"  }  ],
                                 [    ]
                               ]
                            },
                            {  "prim": "PUSH",
                               "args": [
                                 {  "prim": "mutez"  },
                                 {  "int": "0"  }
                               ]
                            },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "32"  }
                               ]
                            },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "5"  }
                               ]
                            },
                            {  "prim": "PUSH",
                               "args": [
                                 {  "prim": "string"  },
                                 {  "string": "V2"  }
                               ]
                            },
                            {  "prim": "PACK"  },
                            {  "prim": "KECCAK"  },
                            {  "prim": "PAIR"  },
                            {  "prim": "EXEC"  },
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
                            {  "prim": "PAIR",
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
                  ]
            }  ],
            [  {  "prim": "IF_LEFT",
                  "args": [
                    [  {  "prim": "IF_LEFT",
                          "args": [
                            [  {  "prim": "UNPAIR"  },
                            {  "prim": "SWAP"  },
                            {  "prim": "DUP",
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
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "7"  }
                               ]
                            },
                            {  "prim": "DUP",
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
                                         {  "string": "matcher"  }
                                       ]
                                 },
                                 {  "prim": "PUSH",
                                    "args": [
                                      {  "prim": "string"  },
                                      {  "string": "KeyExists"  }
                                    ]
                                 },
                                 {  "prim": "PAIR"  },
                                 {  "prim": "FAILWITH"  }  ],
                                 [  {  "prim": "DUP",
                                       "args": [
                                         {  "int": "7"  }
                                       ]
                                 },
                                 {  "prim": "PUSH",
                                    "args": [
                                      {  "prim": "bool"  },
                                      {  "prim": "True"  }
                                    ]
                                 },
                                 {  "prim": "DUP",
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
                                 }  ]
                               ]
                            },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "8"  }
                               ]
                            },
                            {  "prim": "DUP",
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
                                         {  "string": "asset_class_matcher"  }
                                       ]
                                 },
                                 {  "prim": "PUSH",
                                    "args": [
                                      {  "prim": "string"  },
                                      {  "string": "KeyExists"  }
                                    ]
                                 },
                                 {  "prim": "PAIR"  },
                                 {  "prim": "FAILWITH"  }  ],
                                 [  {  "prim": "DUP",
                                       "args": [
                                         {  "int": "8"  }
                                       ]
                                 },
                                 {  "prim": "DUP",
                                    "args": [
                                      {  "int": "2"  }
                                    ]
                                 },
                                 {  "prim": "SOME"  },
                                 {  "prim": "DUP",
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
                                 }  ]
                               ]
                            },
                            {  "prim": "DROP",
                               "args": [
                                 {  "int": "2"  }
                               ]
                            },
                            {  "prim": "PAIR",
                               "args": [
                                 {  "int": "7"  }
                               ]
                            },
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
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "9"  }
                               ]
                            },
                            {  "prim": "SENDER"  },
                            {  "prim": "MEM"  },
                            {  "prim": "SELF_ADDRESS"  },
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
                            {  "prim": "DUP",
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
                            {  "prim": "DUP",
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
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "34"  }
                               ]
                            },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "7"  }
                               ]
                            },
                            {  "prim": "PUSH",
                               "args": [
                                 {  "prim": "string"  },
                                 {  "string": "V2"  }
                               ]
                            },
                            {  "prim": "PACK"  },
                            {  "prim": "KECCAK"  },
                            {  "prim": "PAIR"  },
                            {  "prim": "EXEC"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "35"  }
                               ]
                            },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "7"  }
                               ]
                            },
                            {  "prim": "PUSH",
                               "args": [
                                 {  "prim": "string"  },
                                 {  "string": "V2"  }
                               ]
                            },
                            {  "prim": "PACK"  },
                            {  "prim": "KECCAK"  },
                            {  "prim": "PAIR"  },
                            {  "prim": "EXEC"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "25"  }
                               ]
                            },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "27"  }
                               ]
                            },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "10"  }
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
                            {  "prim": "PUSH",
                               "args": [
                                 {  "prim": "string"  },
                                 {  "string": "V2"  }
                               ]
                            },
                            {  "prim": "PACK"  },
                            {  "prim": "KECCAK"  },
                            {  "prim": "PAIR"  },
                            {  "prim": "EXEC"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "26"  }
                               ]
                            },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "28"  }
                               ]
                            },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "10"  }
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
                            {  "prim": "PUSH",
                               "args": [
                                 {  "prim": "string"  },
                                 {  "string": "V2"  }
                               ]
                            },
                            {  "prim": "PACK"  },
                            {  "prim": "KECCAK"  },
                            {  "prim": "PAIR"  },
                            {  "prim": "EXEC"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "29"  }
                               ]
                            },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "33"  }
                               ]
                            },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "39"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "38"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "37"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "36"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "35"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "3"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "4"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "5"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "6"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "11"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "12"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "16"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "EXEC"  },
                            {  "prim": "DUP"  },
                            {  "prim": "CAR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "2"  }
                               ]
                            },
                            {  "prim": "CDR"  },
                            {  "prim": "CAR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "3"  }
                               ]
                            },
                            {  "prim": "CDR"  },
                            {  "prim": "CDR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "2"  }
                               ]
                            },
                            {  "prim": "IF_NONE",
                               "args": [
                                 [    ],
                                 [  {  "prim": "DUP",
                                       "args": [
                                         {  "int": "23"  }
                                       ]
                                 },
                                 {  "prim": "DUP",
                                    "args": [
                                      {  "int": "20"  }
                                    ]
                                 },
                                 {  "prim": "CONTRACT",
                                    "args": [
                                      {  "prim": "pair",
                                         "args": [
                                           {  "prim": "bytes"  },
                                           {  "prim": "nat"  }
                                         ]
                                      }
                                    ]
                                    ,
                                    "annots": [
                                      "%put"
                                    ]
                                 },
                                 {  "prim": "IF_NONE",
                                    "args": [
                                      [  {  "prim": "PUSH",
                                            "args": [
                                              {  "prim": "string"  },
                                              {  "string": "put"  }
                                            ]
                                      },
                                      {  "prim": "PUSH",
                                         "args": [
                                           {  "prim": "string"  },
                                           {  "string": "EntryNotFound"  }
                                         ]
                                      },
                                      {  "prim": "PAIR"  },
                                      {  "prim": "FAILWITH"  }  ],
                                      [    ]
                                    ]
                                 },
                                 {  "prim": "PUSH",
                                    "args": [
                                      {  "prim": "mutez"  },
                                      {  "int": "0"  }
                                    ]
                                 },
                                 {  "prim": "DUP",
                                    "args": [
                                      {  "int": "4"  }
                                    ]
                                 },
                                 {  "prim": "DUP",
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
                            {  "prim": "DUP"  },
                            {  "prim": "IF_NONE",
                               "args": [
                                 [    ],
                                 [  {  "prim": "DUP",
                                       "args": [
                                         {  "int": "23"  }
                                       ]
                                 },
                                 {  "prim": "DUP",
                                    "args": [
                                      {  "int": "20"  }
                                    ]
                                 },
                                 {  "prim": "CONTRACT",
                                    "args": [
                                      {  "prim": "pair",
                                         "args": [
                                           {  "prim": "bytes"  },
                                           {  "prim": "nat"  }
                                         ]
                                      }
                                    ]
                                    ,
                                    "annots": [
                                      "%put"
                                    ]
                                 },
                                 {  "prim": "IF_NONE",
                                    "args": [
                                      [  {  "prim": "PUSH",
                                            "args": [
                                              {  "prim": "string"  },
                                              {  "string": "put"  }
                                            ]
                                      },
                                      {  "prim": "PUSH",
                                         "args": [
                                           {  "prim": "string"  },
                                           {  "string": "EntryNotFound"  }
                                         ]
                                      },
                                      {  "prim": "PAIR"  },
                                      {  "prim": "FAILWITH"  }  ],
                                      [    ]
                                    ]
                                 },
                                 {  "prim": "PUSH",
                                    "args": [
                                      {  "prim": "mutez"  },
                                      {  "int": "0"  }
                                    ]
                                 },
                                 {  "prim": "DUP",
                                    "args": [
                                      {  "int": "4"  }
                                    ]
                                 },
                                 {  "prim": "DUP",
                                    "args": [
                                      {  "int": "12"  }
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
                                 }  ]
                               ]
                            },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "35"  }
                               ]
                            },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "10"  }
                               ]
                            },
                            {  "prim": "CAR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "12"  }
                               ]
                            },
                            {  "prim": "CAR"  },
                            {  "prim": "PAIR"  },
                            {  "prim": "EXEC"  },
                            {  "prim": "DUP"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "15"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "16"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "5"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "11"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "12"  }
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
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "3"  }
                               ]
                            },
                            {  "prim": "DUP"  },
                            {  "prim": "PUSH",
                               "args": [
                                 {  "prim": "int"  },
                                 {  "int": "0"  }
                               ]
                            },
                            {  "prim": "COMPARE"  },
                            {  "prim": "EQ"  },
                            {  "prim": "IF",
                               "args": [
                                 [  {  "prim": "DUP",
                                       "args": [
                                         {  "int": "2"  }
                                       ]
                                 }  ],
                                 [  {  "prim": "DUP"  },
                                 {  "prim": "PUSH",
                                    "args": [
                                      {  "prim": "int"  },
                                      {  "int": "1"  }
                                    ]
                                 },
                                 {  "prim": "COMPARE"  },
                                 {  "prim": "EQ"  },
                                 {  "prim": "IF",
                                    "args": [
                                      [  {  "prim": "DUP",
                                            "args": [
                                              {  "int": "38"  }
                                            ]
                                      },
                                      {  "prim": "SELF_ADDRESS"  },
                                      {  "prim": "DUP",
                                         "args": [
                                           {  "int": "5"  }
                                         ]
                                      },
                                      {  "prim": "PAIR"  },
                                      {  "prim": "DUP",
                                         "args": [
                                           {  "int": "15"  }
                                         ]
                                      },
                                      {  "prim": "PAIR"  },
                                      {  "prim": "DUP",
                                         "args": [
                                           {  "int": "23"  }
                                         ]
                                      },
                                      {  "prim": "PAIR"  },
                                      {  "prim": "EXEC"  }  ],
                                      [  {  "prim": "DUP",
                                            "args": [
                                              {  "int": "38"  }
                                            ]
                                      },
                                      {  "prim": "SELF_ADDRESS"  },
                                      {  "prim": "DUP",
                                         "args": [
                                           {  "int": "5"  }
                                         ]
                                      },
                                      {  "prim": "PAIR"  },
                                      {  "prim": "DUP",
                                         "args": [
                                           {  "int": "16"  }
                                         ]
                                      },
                                      {  "prim": "PAIR"  },
                                      {  "prim": "DUP",
                                         "args": [
                                           {  "int": "23"  }
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
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "26"  }
                               ]
                            },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "21"  }
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
                                                          {  "prim": "int"  },
                                                          {  "prim": "or",
                                                             "args": [
                                                               {  "prim": "int"  },
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
                                                               {  "prim": "int"  },
                                                               {  "prim": "or",
                                                                  "args": [
                                                                    {  "prim": "int"  },
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
                                                          {  "prim": "bool"  }
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
                                                                    {  "prim": "address"  },
                                                                    {  "prim": "nat"  }
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

                                                                    {  "prim": "address"  },
                                                                    {  "prim": "nat"  }
                                                                    ]
                                                                    }
                                                                  ]
                                                               },
                                                               {  "prim": "bool"  }
                                                             ]
                                                          }
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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
                                                                    {
                                                                    "prim": "pair",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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
                                         {  "string": "doTransfers"  }
                                       ]
                                 },
                                 {  "prim": "PUSH",
                                    "args": [
                                      {  "prim": "string"  },
                                      {  "string": "EntryNotFound"  }
                                    ]
                                 },
                                 {  "prim": "PAIR"  },
                                 {  "prim": "FAILWITH"  }  ],
                                 [    ]
                               ]
                            },
                            {  "prim": "AMOUNT"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "4"  }
                               ]
                            },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "8"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "21"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "22"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "11"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "13"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "14"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "17"  }
                               ]
                            },
                            {  "prim": "PAIR"  },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "18"  }
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
                                         {  "int": "25"  }
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
                                 {  "int": "25"  }
                               ]
                            },
                            {  "prim": "DROP",
                               "args": [
                                 {  "int": "18"  }
                               ]
                            },
                            {  "prim": "PAIR",
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
                    }  ],
                    [  {  "prim": "UNPAIR"  },
                    {  "prim": "SWAP"  },
                    {  "prim": "UNPAIR"  },
                    {  "prim": "SWAP"  },
                    {  "prim": "UNPAIR"  },
                    {  "prim": "SWAP"  },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "17"  }
                       ]
                    },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "21"  }
                       ]
                    },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "21"  }
                       ]
                    },
                    {  "prim": "PAIR"  },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "5"  }
                       ]
                    },
                    {  "prim": "PAIR"  },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "6"  }
                       ]
                    },
                    {  "prim": "PAIR"  },
                    {  "prim": "EXEC"  },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "18"  }
                       ]
                    },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "22"  }
                       ]
                    },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "22"  }
                       ]
                    },
                    {  "prim": "PAIR"  },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "4"  }
                       ]
                    },
                    {  "prim": "PAIR"  },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "5"  }
                       ]
                    },
                    {  "prim": "PAIR"  },
                    {  "prim": "EXEC"  },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "6"  }
                       ]
                    },
                    {  "prim": "CDR"  },
                    {  "prim": "CDR"  },
                    {  "prim": "CAR"  },
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
                         [  {  "prim": "DUP",
                               "args": [
                                 {  "int": "6"  }
                               ]
                         },
                         {  "prim": "CDR"  },
                         {  "prim": "CDR"  },
                         {  "prim": "CAR"  },
                         {  "prim": "DUP",
                            "args": [
                              {  "int": "5"  }
                            ]
                         },
                         {  "prim": "CAR"  },
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
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "4"  }
                       ]
                    },
                    {  "prim": "CDR"  },
                    {  "prim": "CDR"  },
                    {  "prim": "CAR"  },
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
                         [  {  "prim": "DUP",
                               "args": [
                                 {  "int": "6"  }
                               ]
                         },
                         {  "prim": "CAR"  },
                         {  "prim": "DUP",
                            "args": [
                              {  "int": "5"  }
                            ]
                         },
                         {  "prim": "CDR"  },
                         {  "prim": "CDR"  },
                         {  "prim": "CAR"  },
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
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "15"  }
                       ]
                    },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "18"  }
                       ]
                    },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "18"  }
                       ]
                    },
                    {  "prim": "PAIR"  },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "20"  }
                       ]
                    },
                    {  "prim": "PAIR"  },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "6"  }
                       ]
                    },
                    {  "prim": "CDR"  },
                    {  "prim": "CDR"  },
                    {  "prim": "CDR"  },
                    {  "prim": "CAR"  },
                    {  "prim": "CAR"  },
                    {  "prim": "PAIR"  },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "8"  }
                       ]
                    },
                    {  "prim": "CDR"  },
                    {  "prim": "CAR"  },
                    {  "prim": "CAR"  },
                    {  "prim": "PAIR"  },
                    {  "prim": "EXEC"  },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "16"  }
                       ]
                    },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "19"  }
                       ]
                    },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "19"  }
                       ]
                    },
                    {  "prim": "PAIR"  },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "21"  }
                       ]
                    },
                    {  "prim": "PAIR"  },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "7"  }
                       ]
                    },
                    {  "prim": "CDR"  },
                    {  "prim": "CAR"  },
                    {  "prim": "CAR"  },
                    {  "prim": "PAIR"  },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "9"  }
                       ]
                    },
                    {  "prim": "CDR"  },
                    {  "prim": "CDR"  },
                    {  "prim": "CDR"  },
                    {  "prim": "CAR"  },
                    {  "prim": "CAR"  },
                    {  "prim": "PAIR"  },
                    {  "prim": "EXEC"  },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "6"  }
                       ]
                    },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "9"  }
                       ]
                    },
                    {  "prim": "PAIR"  },
                    {  "prim": "PACK"  },
                    {  "prim": "DUP",
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
                    {  "prim": "DUP",
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
                         [  {  "prim": "DUP",
                               "args": [
                                 {  "int": "15"  }
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
                                        {  "prim": "int"  },
                                        {  "prim": "or",
                                           "args": [
                                             {  "prim": "int"  },
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
                                      {  "string": "asset_class_matcher"  }
                                    ]
                              },
                              {  "prim": "PUSH",
                                 "args": [
                                   {  "prim": "string"  },
                                   {  "string": "AssetNotFound"  }
                                 ]
                              },
                              {  "prim": "PAIR"  },
                              {  "prim": "FAILWITH"  }  ],
                              [    ]
                            ]
                         },
                         {  "prim": "DUP",
                            "args": [
                              {  "int": "18"  }
                            ]
                         },
                         {  "prim": "DUP",
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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
                                      {  "string": "matchAssets"  }
                                    ]
                              },
                              {  "prim": "PUSH",
                                 "args": [
                                   {  "prim": "string"  },
                                   {  "string": "EntryNotFound"  }
                                 ]
                              },
                              {  "prim": "PAIR"  },
                              {  "prim": "FAILWITH"  }  ],
                              [    ]
                            ]
                         },
                         {  "prim": "AMOUNT"  },
                         {  "prim": "SELF_ADDRESS"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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
                                      {  "string": "matchAndTransfer"  }
                                    ]
                              },
                              {  "prim": "PUSH",
                                 "args": [
                                   {  "prim": "string"  },
                                   {  "string": "EntryNotFound"  }
                                 ]
                              },
                              {  "prim": "PAIR"  },
                              {  "prim": "FAILWITH"  }  ],
                              [    ]
                            ]
                         },
                         {  "prim": "DUP",
                            "args": [
                              {  "int": "12"  }
                            ]
                         },
                         {  "prim": "PAIR"  },
                         {  "prim": "DUP",
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
                                      {  "int": "17"  }
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
                              {  "int": "17"  }
                            ]
                         },
                         {  "prim": "DROP",
                            "args": [
                              {  "int": "1"  }
                            ]
                         }  ],
                         [  {  "prim": "DUP",
                               "args": [
                                 {  "int": "17"  }
                               ]
                         },
                         {  "prim": "SELF_ADDRESS"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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

                                                                    {  "prim": "int"  },
                                                                    {
                                                                    "prim": "or",
                                                                    "args": [

                                                                    {  "prim": "int"  },
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
                                      {  "string": "matchAndTransfer"  }
                                    ]
                              },
                              {  "prim": "PUSH",
                                 "args": [
                                   {  "prim": "string"  },
                                   {  "string": "EntryNotFound"  }
                                 ]
                              },
                              {  "prim": "PAIR"  },
                              {  "prim": "FAILWITH"  }  ],
                              [    ]
                            ]
                         },
                         {  "prim": "AMOUNT"  },
                         {  "prim": "DUP",
                            "args": [
                              {  "int": "5"  }
                            ]
                         },
                         {  "prim": "DUP",
                            "args": [
                              {  "int": "7"  }
                            ]
                         },
                         {  "prim": "PAIR"  },
                         {  "prim": "DUP",
                            "args": [
                              {  "int": "11"  }
                            ]
                         },
                         {  "prim": "PAIR"  },
                         {  "prim": "DUP",
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
                         }  ]
                       ]
                    },
                    {  "prim": "DROP",
                       "args": [
                         {  "int": "9"  }
                       ]
                    },
                    {  "prim": "PAIR",
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
          ]
       },
       {  "prim": "DIP",
          "args": [
            {  "int": "1"  },
            [  {  "prim": "DROP",
                  "args": [
                    {  "int": "20"  }
                  ]
            }  ]
          ]
       }  ]
     ]
  }  ]

export function validator_storage(
  owner: string,
  exchangeV2: string,
  royaltiesContract: string,
  fill: string) : any {
  return {  "prim": "Pair",
            "args": [
              {  "string": owner  },
              {  "prim": "Pair",
                 "args": [
                   {  "string": exchangeV2  },
                   {  "prim": "Pair",
                      "args": [
                        {  "string": royaltiesContract  },
                        {  "prim": "Pair",
                           "args": [
                             {  "string": fill  },
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
            ]
         }
}

export async function deploy_validator(
  provider : Provider,
  owner: string,
  exchange: string,
  royalties: string,
  fill: string,
) : Promise<OperationResult> {
  const init = validator_storage(owner, exchange, royalties, fill)
  return provider.tezos.originate({init, code: validator_code})
}
