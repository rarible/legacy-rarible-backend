import { Provider, OperationResult } from "../common/base"

export const nft_public_code : any =
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
                    {  "prim": "big_map",
                       "args": [
                         {  "prim": "nat"  },
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
                       ,
                       "annots": [
                         "%royalties"
                       ]
                    },
                    {  "prim": "pair",
                       "args": [
                         {  "prim": "big_map",
                            "args": [
                              {  "prim": "nat"  },
                              {  "prim": "address"  }
                            ]
                            ,
                            "annots": [
                              "%ledger"
                            ]
                         },
                         {  "prim": "pair",
                            "args": [
                              {  "prim": "big_map",
                                 "args": [
                                   {  "prim": "pair",
                                      "args": [
                                        {  "prim": "address"  },
                                        {  "prim": "pair",
                                           "args": [
                                             {  "prim": "nat"  },
                                             {  "prim": "address"  }
                                           ]
                                        }
                                      ]
                                   },
                                   {  "prim": "unit"  }
                                 ]
                                 ,
                                 "annots": [
                                   "%operator"
                                 ]
                              },
                              {  "prim": "pair",
                                 "args": [
                                   {  "prim": "big_map",
                                      "args": [
                                        {  "prim": "nat"  },
                                        {  "prim": "pair",
                                           "args": [
                                             {  "prim": "nat",
                                                "annots": [
                                                  "%token_id"
                                                ]
                                             },
                                             {  "prim": "map",
                                                "args": [
                                                  {  "prim": "string"  },
                                                  {  "prim": "bytes"  }
                                                ]
                                                ,
                                                "annots": [
                                                  "%token_info"
                                                ]
                                             }
                                           ]
                                        }
                                      ]
                                      ,
                                      "annots": [
                                        "%token_metadata"
                                      ]
                                   },
                                   {  "prim": "pair",
                                      "args": [
                                        {  "prim": "big_map",
                                           "args": [
                                             {  "prim": "bytes"  },
                                             {  "prim": "pair",
                                                "args": [
                                                  {  "prim": "timestamp",
                                                     "annots": [
                                                       "%createdAt"
                                                     ]
                                                  },
                                                  {  "prim": "option",
                                                     "args": [
                                                       {  "prim": "int"  }
                                                     ]
                                                     ,
                                                     "annots": [
                                                       "%expiry"
                                                     ]
                                                  }
                                                ]
                                             }
                                           ]
                                           ,
                                           "annots": [
                                             "%permit_info"
                                           ]
                                        },
                                        {  "prim": "pair",
                                           "args": [
                                             {  "prim": "big_map",
                                                "args": [
                                                  {  "prim": "address"  },
                                                  {  "prim": "pair",
                                                     "args": [
                                                       {  "prim": "set",
                                                          "args": [
                                                            {  "prim": "bytes"  }
                                                          ]
                                                          ,
                                                          "annots": [
                                                            "%permits"
                                                          ]
                                                       },
                                                       {  "prim": "pair",
                                                          "args": [
                                                            {  "prim": "option",
                                                               "args": [
                                                                 {  "prim": "int"  }
                                                               ]
                                                               ,
                                                               "annots": [
                                                                 "%globalExpiry"
                                                               ]
                                                            },
                                                            {  "prim": "nat",
                                                               "annots": [
                                                                 "%counter"
                                                               ]
                                                            }
                                                          ]
                                                       }
                                                     ]
                                                  }
                                                ]
                                                ,
                                                "annots": [
                                                  "%permit"
                                                ]
                                             },
                                             {  "prim": "pair",
                                                "args": [
                                                  {  "prim": "big_map",
                                                     "args": [
                                                       {  "prim": "pair",
                                                          "args": [
                                                            {  "prim": "address"  },
                                                            {  "prim": "address"  }
                                                          ]
                                                       },
                                                       {  "prim": "unit"  }
                                                     ]
                                                     ,
                                                     "annots": [
                                                       "%operator_for_all"
                                                     ]
                                                  },
                                                  {  "prim": "pair",
                                                     "args": [
                                                       {  "prim": "int",
                                                          "annots": [
                                                            "%defaultExpiry"
                                                          ]
                                                       },
                                                       {  "prim": "pair",
                                                          "args": [
                                                            {  "prim": "bool",
                                                               "annots": [
                                                                 "%pause"
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
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "list",
                                   "args": [
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "address",
                                             "annots": [
                                               "%owner"
                                             ]
                                          },
                                          {  "prim": "nat",
                                             "annots": [
                                               "%token_id"
                                             ]
                                          }
                                        ]
                                     }
                                   ]
                                   ,
                                   "annots": [
                                     "%requests"
                                   ]
                                },
                                {  "prim": "contract",
                                   "args": [
                                     {  "prim": "list",
                                        "args": [
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "address",
                                                       "annots": [
                                                         "%owner"
                                                       ]
                                                    },
                                                    {  "prim": "nat",
                                                       "annots": [
                                                         "%token_id"
                                                       ]
                                                    }
                                                  ]
                                               },
                                               {  "prim": "nat",
                                                  "annots": [
                                                    "%balance"
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
                                "%balance_of"
                              ]
                           },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "nat",
                                   "annots": [
                                     "%tokenId"
                                   ]
                                },
                                {  "prim": "contract",
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
                                     }
                                   ]
                                }
                              ]
                              ,
                              "annots": [
                                "%getRoyalties"
                              ]
                           }
                         ]
                      },
                      {  "prim": "or",
                         "args": [
                           {  "prim": "list",
                              "args": [
                                {  "prim": "or",
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
                                                    "%operator"
                                                  ]
                                               },
                                               {  "prim": "nat",
                                                  "annots": [
                                                    "%token_id"
                                                  ]
                                               }
                                             ]
                                          }
                                        ]
                                     },
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
                                                    "%operator"
                                                  ]
                                               },
                                               {  "prim": "nat",
                                                  "annots": [
                                                    "%token_id"
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
                                "%update_operators"
                              ]
                           },
                           {  "prim": "list",
                              "args": [
                                {  "prim": "or",
                                   "args": [
                                     {  "prim": "address"  },
                                     {  "prim": "address"  }
                                   ]
                                }
                              ]
                              ,
                              "annots": [
                                "%update_operators_for_all"
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
                           {  "prim": "nat",
                              "annots": [
                                "%burn"
                              ]
                           },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "string",
                                   "annots": [
                                     "%ikey"
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
                                "%setMetadata"
                              ]
                           }
                         ]
                      },
                      {  "prim": "or",
                         "args": [
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "nat",
                                   "annots": [
                                     "%iTokenId"
                                   ]
                                },
                                {  "prim": "map",
                                   "args": [
                                     {  "prim": "string"  },
                                     {  "prim": "bytes"  }
                                   ]
                                   ,
                                   "annots": [
                                     "%iExtras"
                                   ]
                                }
                              ]
                              ,
                              "annots": [
                                "%setTokenMetadata"
                              ]
                           },
                           {  "prim": "bool",
                              "annots": [
                                "%setPause"
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
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "key",
                                   "annots": [
                                     "%pk"
                                   ]
                                },
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "signature",
                                        "annots": [
                                          "%s"
                                        ]
                                     },
                                     {  "prim": "bytes",
                                        "annots": [
                                          "%permitkey"
                                        ]
                                     }
                                   ]
                                }
                              ]
                              ,
                              "annots": [
                                "%addPermit"
                              ]
                           },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "address",
                                   "annots": [
                                     "%expectedUser"
                                   ]
                                },
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "bytes",
                                        "annots": [
                                          "%permitkey"
                                        ]
                                     },
                                     {  "prim": "string",
                                        "annots": [
                                          "%errMessage"
                                        ]
                                     }
                                   ]
                                }
                              ]
                              ,
                              "annots": [
                                "%consumePermit"
                              ]
                           }
                         ]
                      },
                      {  "prim": "or",
                         "args": [
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "address",
                                   "annots": [
                                     "%powner"
                                   ]
                                },
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "int",
                                        "annots": [
                                          "%newExpiry"
                                        ]
                                     },
                                     {  "prim": "option",
                                        "args": [
                                          {  "prim": "bytes"  }
                                        ]
                                        ,
                                        "annots": [
                                          "%specificPermitOrDefault"
                                        ]
                                     }
                                   ]
                                }
                              ]
                              ,
                              "annots": [
                                "%setExpiry"
                              ]
                           },
                           {  "prim": "list",
                              "args": [
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "address"  },
                                     {  "prim": "list",
                                        "args": [
                                          {  "prim": "pair",
                                             "args": [
                                               {  "prim": "address",
                                                  "annots": [
                                                    "%to"
                                                  ]
                                               },
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "nat",
                                                       "annots": [
                                                         "%token_id"
                                                       ]
                                                    },
                                                    {  "prim": "nat",
                                                       "annots": [
                                                         "%amount"
                                                       ]
                                                    }
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
                                "%transferOwnership"
                              ]
                           },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "nat",
                                   "annots": [
                                     "%tokenId"
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
                                     "%value"
                                   ]
                                }
                              ]
                              ,
                              "annots": [
                                "%setRoyalties"
                              ]
                           }
                         ]
                      },
                      {  "prim": "pair",
                         "args": [
                           {  "prim": "nat",
                              "annots": [
                                "%itokenid"
                              ]
                           },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "address",
                                   "annots": [
                                     "%iowner"
                                   ]
                                },
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "map",
                                        "args": [
                                          {  "prim": "string"  },
                                          {  "prim": "bytes"  }
                                        ]
                                        ,
                                        "annots": [
                                          "%itokenMetadata"
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
                                          "%iroyalties"
                                        ]
                                     }
                                   ]
                                }
                              ]
                           }
                         ]
                         ,
                         "annots": [
                           "%mint"
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
  {  "prim": "code",
     "args": [
       [  {  "prim": "LAMBDA",
             "args": [
               {  "prim": "pair",
                  "args": [
                    {  "prim": "big_map",
                       "args": [
                         {  "prim": "nat"  },
                         {  "prim": "address"  }
                       ]
                    },
                    {  "prim": "pair",
                       "args": [
                         {  "prim": "big_map",
                            "args": [
                              {  "prim": "pair",
                                 "args": [
                                   {  "prim": "address"  },
                                   {  "prim": "address"  }
                                 ]
                              },
                              {  "prim": "unit"  }
                            ]
                         },
                         {  "prim": "pair",
                            "args": [
                              {  "prim": "big_map",
                                 "args": [
                                   {  "prim": "pair",
                                      "args": [
                                        {  "prim": "address"  },
                                        {  "prim": "pair",
                                           "args": [
                                             {  "prim": "nat"  },
                                             {  "prim": "address"  }
                                           ]
                                        }
                                      ]
                                   },
                                   {  "prim": "unit"  }
                                 ]
                              },
                              {  "prim": "list",
                                 "args": [
                                   {  "prim": "pair",
                                      "args": [
                                        {  "prim": "address"  },
                                        {  "prim": "list",
                                           "args": [
                                             {  "prim": "pair",
                                                "args": [
                                                  {  "prim": "address",
                                                     "annots": [
                                                       "%to"
                                                     ]
                                                  },
                                                  {  "prim": "pair",
                                                     "args": [
                                                       {  "prim": "nat",
                                                          "annots": [
                                                            "%token_id"
                                                          ]
                                                       },
                                                       {  "prim": "nat",
                                                          "annots": [
                                                            "%amount"
                                                          ]
                                                       }
                                                     ]
                                                  }
                                                ]
                                             }
                                           ]
                                        }
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
               {  "prim": "PUSH",
                  "args": [
                    {  "prim": "bool"  },
                    {  "prim": "True"  }
                  ]
               },
               {  "prim": "DUP",
                  "args": [
                    {  "int": "6"  }
                  ]
               },
               {  "prim": "ITER",
                  "args": [
                    [  {  "prim": "DUP"  },
                    {  "prim": "CAR"  },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "2"  }
                       ]
                    },
                    {  "prim": "CDR"  },
                    {  "prim": "DUP"  },
                    {  "prim": "ITER",
                       "args": [
                         [  {  "prim": "DUP",
                               "args": [
                                 {  "int": "3"  }
                               ]
                         },
                         {  "prim": "SENDER"  },
                         {  "prim": "COMPARE"  },
                         {  "prim": "NEQ"  },
                         {  "prim": "IF",
                            "args": [
                              [  {  "prim": "DUP",
                                    "args": [
                                      {  "int": "8"  }
                                    ]
                              },
                              {  "prim": "SENDER"  },
                              {  "prim": "DUP",
                                 "args": [
                                   {  "int": "5"  }
                                 ]
                              },
                              {  "prim": "PAIR"  },
                              {  "prim": "MEM"  },
                              {  "prim": "DUP",
                                 "args": [
                                   {  "int": "10"  }
                                 ]
                              },
                              {  "prim": "DUP",
                                 "args": [
                                   {  "int": "5"  }
                                 ]
                              },
                              {  "prim": "DUP",
                                 "args": [
                                   {  "int": "4"  }
                                 ]
                              },
                              {  "prim": "CDR"  },
                              {  "prim": "CAR"  },
                              {  "prim": "PAIR"  },
                              {  "prim": "SENDER"  },
                              {  "prim": "PAIR"  },
                              {  "prim": "MEM"  },
                              {  "prim": "OR"  }  ],
                              [  {  "prim": "SENDER"  },
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
                              {  "prim": "CDR"  },
                              {  "prim": "CAR"  },
                              {  "prim": "GET"  },
                              {  "prim": "IF_NONE",
                                 "args": [
                                   [  {  "prim": "PUSH",
                                         "args": [
                                           {  "prim": "string"  },
                                           {  "string": "ledger"  }
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
                              {  "prim": "COMPARE"  },
                              {  "prim": "EQ"  }  ]
                            ]
                         },
                         {  "prim": "DUP",
                            "args": [
                              {  "int": "6"  }
                            ]
                         },
                         {  "prim": "AND"  },
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
                 {  "prim": "string"  },
                 {  "prim": "list",
                    "args": [
                      {  "prim": "pair",
                         "args": [
                           {  "prim": "address"  },
                           {  "prim": "list",
                              "args": [
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "address",
                                        "annots": [
                                          "%to"
                                        ]
                                     },
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "nat",
                                             "annots": [
                                               "%token_id"
                                             ]
                                          },
                                          {  "prim": "nat",
                                             "annots": [
                                               "%amount"
                                             ]
                                          }
                                        ]
                                     }
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
                 {  "prim": "address"  }
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
            {  "prim": "IF_CONS",
               "args": [
                 [  {  "prim": "DUP"  },
                 {  "prim": "CAR"  },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "ITER",
                    "args": [
                      [  {  "prim": "DUP"  },
                      {  "prim": "CAR"  },
                      {  "prim": "DUP",
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
                                   {  "string": "FA2_NOT_OPERATOR"  }
                                 ]
                           },
                           {  "prim": "FAILWITH"  }  ],
                           [    ]
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
                 },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "3"  }
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
                 {  "prim": "int"  },
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "big_map",
                         "args": [
                           {  "prim": "bytes"  },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "timestamp",
                                   "annots": [
                                     "%createdAt"
                                   ]
                                },
                                {  "prim": "option",
                                   "args": [
                                     {  "prim": "int"  }
                                   ]
                                   ,
                                   "annots": [
                                     "%expiry"
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
            {  "prim": "DUP",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "MEM"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "DUP",
                       "args": [
                         {  "int": "3"  }
                       ]
                 },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "5"  }
                    ]
                 },
                 {  "prim": "GET"  },
                 {  "prim": "IF_NONE",
                    "args": [
                      [  {  "prim": "PUSH",
                            "args": [
                              {  "prim": "string"  },
                              {  "string": "permit_info"  }
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
                 {  "prim": "CDR"  },
                 {  "prim": "IF_NONE",
                    "args": [
                      [  {  "prim": "DUP",
                            "args": [
                              {  "int": "2"  }
                            ]
                      }  ],
                      [    ]
                    ]
                 },
                 {  "prim": "NOW"  },
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
                 {  "prim": "GET"  },
                 {  "prim": "IF_NONE",
                    "args": [
                      [  {  "prim": "PUSH",
                            "args": [
                              {  "prim": "string"  },
                              {  "string": "permit_info"  }
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
                 {  "prim": "CAR"  },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "3"  }
                    ]
                 },
                 {  "prim": "ADD"  },
                 {  "prim": "COMPARE"  },
                 {  "prim": "LT"  },
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
                 {  "prim": "int"  },
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "big_map",
                         "args": [
                           {  "prim": "bytes"  },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "timestamp",
                                   "annots": [
                                     "%createdAt"
                                   ]
                                },
                                {  "prim": "option",
                                   "args": [
                                     {  "prim": "int"  }
                                   ]
                                   ,
                                   "annots": [
                                     "%expiry"
                                   ]
                                }
                              ]
                           }
                         ]
                      },
                      {  "prim": "pair",
                         "args": [
                           {  "prim": "big_map",
                              "args": [
                                {  "prim": "address"  },
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "set",
                                        "args": [
                                          {  "prim": "bytes"  }
                                        ]
                                        ,
                                        "annots": [
                                          "%permits"
                                        ]
                                     },
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "option",
                                             "args": [
                                               {  "prim": "int"  }
                                             ]
                                             ,
                                             "annots": [
                                               "%globalExpiry"
                                             ]
                                          },
                                          {  "prim": "nat",
                                             "annots": [
                                               "%counter"
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
                                {  "prim": "address"  },
                                {  "prim": "pair",
                                   "args": [
                                     {  "prim": "bytes"  },
                                     {  "prim": "pair",
                                        "args": [
                                          {  "prim": "string"  },
                                          {  "prim": "lambda",
                                             "args": [
                                               {  "prim": "pair",
                                                  "args": [
                                                    {  "prim": "int"  },
                                                    {  "prim": "pair",
                                                       "args": [
                                                         {  "prim": "big_map",
                                                            "args": [
                                                              {  "prim": "bytes"  },
                                                              {  "prim": "pair",
                                                                 "args": [
                                                                   {
                                                                   "prim": "timestamp",
                                                                   "annots": [

                                                                   "%createdAt"
                                                                   ]
                                                                   },
                                                                   {
                                                                   "prim": "option",
                                                                   "args": [

                                                                   {  "prim": "int"  }
                                                                   ]
                                                                   ,
                                                                   "annots": [

                                                                   "%expiry"
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
                      }
                    ]
                 }
               ]
            },
            {  "prim": "bool"  },
            [  {  "prim": "UNPAIR",
                  "args": [
                    {  "int": "7"  }
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
            {  "prim": "SENDER"  },
            {  "prim": "COMPARE"  },
            {  "prim": "NEQ"  },
            {  "prim": "IF",
               "args": [
                 [  {  "prim": "DUP",
                       "args": [
                         {  "int": "4"  }
                       ]
                 },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "6"  }
                    ]
                 },
                 {  "prim": "MEM"  },
                 {  "prim": "NOT"  },
                 {  "prim": "IF",
                    "args": [
                      [  {  "prim": "DUP",
                            "args": [
                              {  "int": "7"  }
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
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "7"  }
                    ]
                 },
                 {  "prim": "MEM"  },
                 {  "prim": "NOT"  },
                 {  "prim": "IF",
                    "args": [
                      [  {  "prim": "DUP",
                            "args": [
                              {  "int": "7"  }
                            ]
                      },
                      {  "prim": "FAILWITH"  }  ],
                      [    ]
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
                 {  "prim": "IF",
                    "args": [
                      [  {  "prim": "PUSH",
                            "args": [
                              {  "prim": "string"  },
                              {  "string": "EXPIRED_PERMIT"  }
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
                 {  "prim": "SWAP"  },
                 {  "prim": "DROP",
                    "args": [
                      {  "int": "1"  }
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
            {  "prim": "DUG",
               "args": [
                 {  "int": "7"  }
               ]
            },
            {  "prim": "DROP",
               "args": [
                 {  "int": "7"  }
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
       {  "prim": "UNPAIR"  },
       {  "prim": "DIP",
          "args": [
            {  "int": "1"  },
            [  {  "prim": "UNPAIR",
                  "args": [
                    {  "int": "11"  }
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
                            [  {  "prim": "IF_LEFT",
                                  "args": [
                                    [  {  "prim": "UNPAIR"  },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "14"  }
                                       ]
                                    },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "3"  }
                                       ]
                                    },
                                    {  "prim": "AMOUNT"  },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "4"  }
                                       ]
                                    },
                                    {  "prim": "MAP",
                                       "args": [
                                         [  {  "prim": "DUP"  },
                                         {  "prim": "CAR"  },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "10"  }
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "3"  }
                                            ]
                                         },
                                         {  "prim": "CDR"  },
                                         {  "prim": "GET"  },
                                         {  "prim": "IF_NONE",
                                            "args": [
                                              [  {  "prim": "PUSH",
                                                    "args": [
                                                      {  "prim": "string"  },
                                                      {  "string": "ledger"  }
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
                                         {  "prim": "COMPARE"  },
                                         {  "prim": "EQ"  },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "10"  }
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "3"  }
                                            ]
                                         },
                                         {  "prim": "CDR"  },
                                         {  "prim": "MEM"  },
                                         {  "prim": "AND"  },
                                         {  "prim": "IF",
                                            "args": [
                                              [  {  "prim": "PUSH",
                                                    "args": [
                                                      {  "prim": "nat"  },
                                                      {  "int": "1"  }
                                                    ]
                                              }  ],
                                              [  {  "prim": "PUSH",
                                                    "args": [
                                                      {  "prim": "nat"  },
                                                      {  "int": "0"  }
                                                    ]
                                              }  ]
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "2"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "SWAP"  },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         }  ]
                                       ]
                                    },
                                    {  "prim": "TRANSFER_TOKENS"  },
                                    {  "prim": "CONS"  },
                                    {  "prim": "DIP",
                                       "args": [
                                         {  "int": "1"  },
                                         [  {  "prim": "DIG",
                                               "args": [
                                                 {  "int": "13"  }
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
                                         {  "int": "13"  }
                                       ]
                                    },
                                    {  "prim": "DROP",
                                       "args": [
                                         {  "int": "2"  }
                                       ]
                                    },
                                    {  "prim": "PAIR",
                                       "args": [
                                         {  "int": "11"  }
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "PAIR"  }  ],
                                    [  {  "prim": "UNPAIR"  },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "14"  }
                                       ]
                                    },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "3"  }
                                       ]
                                    },
                                    {  "prim": "AMOUNT"  },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "7"  }
                                       ]
                                    },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "5"  }
                                       ]
                                    },
                                    {  "prim": "GET"  },
                                    {  "prim": "IF_NONE",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "royalties"  }
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
                                    {  "prim": "TRANSFER_TOKENS"  },
                                    {  "prim": "CONS"  },
                                    {  "prim": "DIP",
                                       "args": [
                                         {  "int": "1"  },
                                         [  {  "prim": "DIG",
                                               "args": [
                                                 {  "int": "13"  }
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
                                         {  "int": "13"  }
                                       ]
                                    },
                                    {  "prim": "DROP",
                                       "args": [
                                         {  "int": "2"  }
                                       ]
                                    },
                                    {  "prim": "PAIR",
                                       "args": [
                                         {  "int": "11"  }
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
                                            {  "int": "11"  }
                                          ]
                                    },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "CONTRACT_PAUSED"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "ITER",
                                       "args": [
                                         [  {  "prim": "DUP"  },
                                         {  "prim": "IF_LEFT",
                                            "args": [
                                              [  {  "prim": "SENDER"  },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "2"  }
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
                                                           {  "string": "CALLER NOT OWNER"  }
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
                                              {  "prim": "CAR"  },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "3"  }
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
                                              {  "prim": "CDR"  },
                                              {  "prim": "CAR"  },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "MEM"  },
                                              {  "prim": "IF",
                                                 "args": [
                                                   [  {  "prim": "PUSH",
                                                         "args": [
                                                           {  "prim": "string"  },
                                                           {  "string": "operator"  }
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
                                                        {  "prim": "unit"  },
                                                        {  "prim": "Unit"  }
                                                      ]
                                                   },
                                                   {  "prim": "SOME"  },
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
                                                   {  "prim": "CDR"  },
                                                   {  "prim": "PAIR"  },
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "4"  }
                                                      ]
                                                   },
                                                   {  "prim": "CDR"  },
                                                   {  "prim": "CAR"  },
                                                   {  "prim": "PAIR"  },
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
                                              {  "prim": "CAR"  },
                                              {  "prim": "COMPARE"  },
                                              {  "prim": "EQ"  },
                                              {  "prim": "NOT"  },
                                              {  "prim": "IF",
                                                 "args": [
                                                   [  {  "prim": "PUSH",
                                                         "args": [
                                                           {  "prim": "string"  },
                                                           {  "string": "CALLER NOT OWNER"  }
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
                                              {  "prim": "NONE",
                                                 "args": [
                                                   {  "prim": "unit"  }
                                                 ]
                                              },
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
                                              {  "prim": "CDR"  },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "4"  }
                                                 ]
                                              },
                                              {  "prim": "CDR"  },
                                              {  "prim": "CAR"  },
                                              {  "prim": "PAIR"  },
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
                                    },
                                    {  "prim": "PAIR",
                                       "args": [
                                         {  "int": "11"  }
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "PAIR"  }  ],
                                    [  {  "prim": "DUP"  },
                                    {  "prim": "ITER",
                                       "args": [
                                         [  {  "prim": "DUP"  },
                                         {  "prim": "IF_LEFT",
                                            "args": [
                                              [  {  "prim": "DUP",
                                                    "args": [
                                                      {  "int": "11"  }
                                                    ]
                                              },
                                              {  "prim": "SENDER"  },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "3"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "MEM"  },
                                              {  "prim": "IF",
                                                 "args": [
                                                   [  {  "prim": "PUSH",
                                                         "args": [
                                                           {  "prim": "string"  },
                                                           {  "string": "operator_for_all"  }
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
                                                           {  "int": "11"  }
                                                         ]
                                                   },
                                                   {  "prim": "PUSH",
                                                      "args": [
                                                        {  "prim": "unit"  },
                                                        {  "prim": "Unit"  }
                                                      ]
                                                   },
                                                   {  "prim": "SOME"  },
                                                   {  "prim": "SENDER"  },
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "4"  }
                                                      ]
                                                   },
                                                   {  "prim": "PAIR"  },
                                                   {  "prim": "UPDATE"  },
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
                                                   }  ]
                                                 ]
                                              },
                                              {  "prim": "DROP",
                                                 "args": [
                                                   {  "int": "1"  }
                                                 ]
                                              }  ],
                                              [  {  "prim": "DUP",
                                                    "args": [
                                                      {  "int": "11"  }
                                                    ]
                                              },
                                              {  "prim": "NONE",
                                                 "args": [
                                                   {  "prim": "unit"  }
                                                 ]
                                              },
                                              {  "prim": "SENDER"  },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "4"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "UPDATE"  },
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
                                    },
                                    {  "prim": "PAIR",
                                       "args": [
                                         {  "int": "11"  }
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
                                    [  {  "prim": "DUP",
                                          "args": [
                                            {  "int": "11"  }
                                          ]
                                    },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "CONTRACT_PAUSED"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "SENDER"  },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "5"  }
                                       ]
                                    },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "3"  }
                                       ]
                                    },
                                    {  "prim": "GET"  },
                                    {  "prim": "IF_NONE",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "ledger"  }
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
                                    {  "prim": "COMPARE"  },
                                    {  "prim": "EQ"  },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "5"  }
                                       ]
                                    },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "3"  }
                                       ]
                                    },
                                    {  "prim": "MEM"  },
                                    {  "prim": "AND"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "DUP",
                                               "args": [
                                                 {  "int": "4"  }
                                               ]
                                         },
                                         {  "prim": "NONE",
                                            "args": [
                                              {  "prim": "address"  }
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
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "6"  }
                                            ]
                                         },
                                         {  "prim": "NONE",
                                            "args": [
                                              {  "prim": "pair",
                                                 "args": [
                                                   {  "prim": "nat"  },
                                                   {  "prim": "map",
                                                      "args": [
                                                        {  "prim": "string"  },
                                                        {  "prim": "bytes"  }
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
                                         {  "prim": "UPDATE"  },
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
                                         }  ],
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "CALLER NOT OWNER"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ]
                                       ]
                                    },
                                    {  "prim": "DROP",
                                       "args": [
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "PAIR",
                                       "args": [
                                         {  "int": "11"  }
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
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "12"  }
                                       ]
                                    },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "CONTRACT_PAUSED"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DIG",
                                       "args": [
                                         {  "int": "12"  }
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
                                    {  "prim": "DUG",
                                       "args": [
                                         {  "int": "12"  }
                                       ]
                                    },
                                    {  "prim": "DROP",
                                       "args": [
                                         {  "int": "2"  }
                                       ]
                                    },
                                    {  "prim": "PAIR",
                                       "args": [
                                         {  "int": "11"  }
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
                                    [  {  "prim": "UNPAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "SELF_ADDRESS"  },
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
                                         {  "int": "12"  }
                                       ]
                                    },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "CONTRACT_PAUSED"  }
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
                                         {  "int": "3"  }
                                       ]
                                    },
                                    {  "prim": "MEM"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "DUP",
                                               "args": [
                                                 {  "int": "7"  }
                                               ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "8"  }
                                            ]
                                         },
                                         {  "prim": "DUP",
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
                                                      {  "string": "token_metadata"  }
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
                                         {  "prim": "UNPAIR"  },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "4"  }
                                            ]
                                         },
                                         {  "prim": "SWAP"  },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "3"  }
                                            ]
                                         },
                                         {  "prim": "SWAP"  },
                                         {  "prim": "PAIR"  },
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
                                         }  ],
                                         [  {  "prim": "DUP",
                                               "args": [
                                                 {  "int": "7"  }
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
                                                      {  "string": "token_metadata"  }
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
                                         {  "int": "11"  }
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
                                         {  "int": "1"  }
                                       ]
                                    },
                                    {  "prim": "PAIR",
                                       "args": [
                                         {  "int": "11"  }
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
                    }  ]
                  ]
            }  ],
            [  {  "prim": "IF_LEFT",
                  "args": [
                    [  {  "prim": "IF_LEFT",
                          "args": [
                            [  {  "prim": "IF_LEFT",
                                  "args": [
                                    [  {  "prim": "UNPAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "UNPAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "13"  }
                                       ]
                                    },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "CONTRACT_PAUSED"  }
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
                                    {  "prim": "HASH_KEY"  },
                                    {  "prim": "IMPLICIT_ACCOUNT"  },
                                    {  "prim": "ADDRESS"  },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "11"  }
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
                                         [  {  "prim": "DUP",
                                               "args": [
                                                 {  "int": "11"  }
                                               ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "2"  }
                                            ]
                                         },
                                         {  "prim": "GET"  },
                                         {  "prim": "IF_NONE",
                                            "args": [
                                              [  {  "prim": "PUSH",
                                                    "args": [
                                                      {  "prim": "string"  },
                                                      {  "string": "permit"  }
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
                                         {  "prim": "CAR"  },
                                         {  "prim": "ITER",
                                            "args": [
                                              [  {  "prim": "DUP",
                                                    "args": [
                                                      {  "int": "11"  }
                                                    ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "2"  }
                                                 ]
                                              },
                                              {  "prim": "GET"  },
                                              {  "prim": "IF_NONE",
                                                 "args": [
                                                   [  {  "prim": "PUSH",
                                                         "args": [
                                                           {  "prim": "string"  },
                                                           {  "string": "permit"  }
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
                                                   {  "int": "20"  }
                                                 ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "3"  }
                                                 ]
                                              },
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
                                              {  "prim": "EXEC"  },
                                              {  "prim": "IF",
                                                 "args": [
                                                   [  {  "prim": "DUP",
                                                         "args": [
                                                           {  "int": "12"  }
                                                         ]
                                                   },
                                                   {  "prim": "NONE",
                                                      "args": [
                                                        {  "prim": "pair",
                                                           "args": [
                                                             {  "prim": "timestamp"  },
                                                             {  "prim": "option",
                                                                "args": [
                                                                  {  "prim": "int"  }
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
                                                   {  "prim": "UPDATE"  },
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
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "13"  }
                                                      ]
                                                   },
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "14"  }
                                                      ]
                                                   },
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "5"  }
                                                      ]
                                                   },
                                                   {  "prim": "GET"  },
                                                   {  "prim": "IF_NONE",
                                                      "args": [
                                                        [  {  "prim": "PUSH",
                                                              "args": [
                                                                {  "prim": "string"  },
                                                                {  "string": "permit"  }
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
                                                   {  "prim": "UNPAIR"  },
                                                   {  "prim": "DROP",
                                                      "args": [
                                                        {  "int": "1"  }
                                                      ]
                                                   },
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "15"  }
                                                      ]
                                                   },
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "6"  }
                                                      ]
                                                   },
                                                   {  "prim": "GET"  },
                                                   {  "prim": "IF_NONE",
                                                      "args": [
                                                        [  {  "prim": "PUSH",
                                                              "args": [
                                                                {  "prim": "string"  },
                                                                {  "string": "permit"  }
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
                                                   {  "prim": "CAR"  },
                                                   {  "prim": "PUSH",
                                                      "args": [
                                                        {  "prim": "bool"  },
                                                        {  "prim": "False"  }
                                                      ]
                                                   },
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "6"  }
                                                      ]
                                                   },
                                                   {  "prim": "UPDATE"  },
                                                   {  "prim": "PAIR"  },
                                                   {  "prim": "SOME"  },
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "5"  }
                                                      ]
                                                   },
                                                   {  "prim": "UPDATE"  },
                                                   {  "prim": "DIP",
                                                      "args": [
                                                        {  "int": "1"  },
                                                        [  {  "prim": "DIG",
                                                              "args": [
                                                                {  "int": "12"  }
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
                                                        {  "int": "12"  }
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
                                         }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "11"  }
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
                                         [  {  "prim": "DUP",
                                               "args": [
                                                 {  "int": "11"  }
                                               ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "2"  }
                                            ]
                                         },
                                         {  "prim": "GET"  },
                                         {  "prim": "IF_NONE",
                                            "args": [
                                              [  {  "prim": "PUSH",
                                                    "args": [
                                                      {  "prim": "string"  },
                                                      {  "string": "permit"  }
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
                                         {  "prim": "CDR"  },
                                         {  "prim": "CDR"  }  ],
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "nat"  },
                                                 {  "int": "0"  }
                                               ]
                                         }  ]
                                       ]
                                    },
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
                                    {  "prim": "PAIR"  },
                                    {  "prim": "CHAIN_ID"  },
                                    {  "prim": "SELF_ADDRESS"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "PACK"  },
                                    {  "prim": "DUP"  },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "6"  }
                                       ]
                                    },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "8"  }
                                       ]
                                    },
                                    {  "prim": "CHECK_SIGNATURE"  },
                                    {  "prim": "NOT"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "DUP"  },
                                         {  "prim": "PUSH",
                                            "args": [
                                              {  "prim": "string"  },
                                              {  "string": "MISSIGNED"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "20"  }
                                       ]
                                    },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "5"  }
                                       ]
                                    },
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
                                    {  "prim": "EXEC"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "EXPIRED_PERMIT"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "13"  }
                                       ]
                                    },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "4"  }
                                       ]
                                    },
                                    {  "prim": "MEM"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "DUP",
                                               "args": [
                                                 {  "int": "13"  }
                                               ]
                                         },
                                         {  "prim": "DUP",
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
                                                      {  "string": "permit"  }
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
                                              {  "int": "14"  }
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "15"  }
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "6"  }
                                            ]
                                         },
                                         {  "prim": "GET"  },
                                         {  "prim": "IF_NONE",
                                            "args": [
                                              [  {  "prim": "PUSH",
                                                    "args": [
                                                      {  "prim": "string"  },
                                                      {  "string": "permit"  }
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
                                         {  "prim": "UNPAIR"  },
                                         {  "prim": "SWAP"  },
                                         {  "prim": "UNPAIR"  },
                                         {  "prim": "SWAP"  },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         },
                                         {  "prim": "PUSH",
                                            "args": [
                                              {  "prim": "nat"  },
                                              {  "int": "1"  }
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "5"  }
                                            ]
                                         },
                                         {  "prim": "CDR"  },
                                         {  "prim": "CDR"  },
                                         {  "prim": "ADD"  },
                                         {  "prim": "SWAP"  },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "SWAP"  },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "SOME"  },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "6"  }
                                            ]
                                         },
                                         {  "prim": "UPDATE"  },
                                         {  "prim": "DIP",
                                            "args": [
                                              {  "int": "1"  },
                                              [  {  "prim": "DIG",
                                                    "args": [
                                                      {  "int": "13"  }
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
                                              {  "int": "13"  }
                                            ]
                                         },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         }  ],
                                         [  {  "prim": "DUP",
                                               "args": [
                                                 {  "int": "13"  }
                                               ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "4"  }
                                            ]
                                         },
                                         {  "prim": "MEM"  },
                                         {  "prim": "IF",
                                            "args": [
                                              [  {  "prim": "PUSH",
                                                    "args": [
                                                      {  "prim": "string"  },
                                                      {  "string": "permit"  }
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
                                                      {  "int": "13"  }
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
                                                   {  "int": "0"  }
                                                 ]
                                              },
                                              {  "prim": "ADD"  },
                                              {  "prim": "NONE",
                                                 "args": [
                                                   {  "prim": "int"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "EMPTY_SET",
                                                 "args": [
                                                   {  "prim": "bytes"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "SOME"  },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "5"  }
                                                 ]
                                              },
                                              {  "prim": "UPDATE"  },
                                              {  "prim": "DIP",
                                                 "args": [
                                                   {  "int": "1"  },
                                                   [  {  "prim": "DIG",
                                                         "args": [
                                                           {  "int": "12"  }
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
                                                   {  "int": "12"  }
                                                 ]
                                              }  ]
                                            ]
                                         }  ]
                                       ]
                                    },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "12"  }
                                       ]
                                    },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "5"  }
                                       ]
                                    },
                                    {  "prim": "MEM"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "DUP",
                                               "args": [
                                                 {  "int": "13"  }
                                               ]
                                         },
                                         {  "prim": "DUP",
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
                                                      {  "string": "permit"  }
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
                                         {  "prim": "CAR"  },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "5"  }
                                            ]
                                         },
                                         {  "prim": "MEM"  },
                                         {  "prim": "IF",
                                            "args": [
                                              [    ],
                                              [  {  "prim": "DUP",
                                                    "args": [
                                                      {  "int": "4"  }
                                                    ]
                                              },
                                              {  "prim": "PUSH",
                                                 "args": [
                                                   {  "prim": "string"  },
                                                   {  "string": "KeyNotFound"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "FAILWITH"  }  ]
                                            ]
                                         }  ],
                                         [  {  "prim": "DUP",
                                               "args": [
                                                 {  "int": "12"  }
                                               ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "5"  }
                                            ]
                                         },
                                         {  "prim": "MEM"  },
                                         {  "prim": "IF",
                                            "args": [
                                              [  {  "prim": "PUSH",
                                                    "args": [
                                                      {  "prim": "string"  },
                                                      {  "string": "permit_info"  }
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
                                                      {  "int": "12"  }
                                                    ]
                                              },
                                              {  "prim": "NONE",
                                                 "args": [
                                                   {  "prim": "int"  }
                                                 ]
                                              },
                                              {  "prim": "NOW"  },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "SOME"  },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "6"  }
                                                 ]
                                              },
                                              {  "prim": "UPDATE"  },
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
                                              }  ]
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "13"  }
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "14"  }
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "5"  }
                                            ]
                                         },
                                         {  "prim": "GET"  },
                                         {  "prim": "IF_NONE",
                                            "args": [
                                              [  {  "prim": "PUSH",
                                                    "args": [
                                                      {  "prim": "string"  },
                                                      {  "string": "permit"  }
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
                                         {  "prim": "UNPAIR"  },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "15"  }
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "6"  }
                                            ]
                                         },
                                         {  "prim": "GET"  },
                                         {  "prim": "IF_NONE",
                                            "args": [
                                              [  {  "prim": "PUSH",
                                                    "args": [
                                                      {  "prim": "string"  },
                                                      {  "string": "permit"  }
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
                                         {  "prim": "CAR"  },
                                         {  "prim": "PUSH",
                                            "args": [
                                              {  "prim": "bool"  },
                                              {  "prim": "True"  }
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "8"  }
                                            ]
                                         },
                                         {  "prim": "UPDATE"  },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "SOME"  },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "5"  }
                                            ]
                                         },
                                         {  "prim": "UPDATE"  },
                                         {  "prim": "DIP",
                                            "args": [
                                              {  "int": "1"  },
                                              [  {  "prim": "DIG",
                                                    "args": [
                                                      {  "int": "12"  }
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
                                              {  "int": "12"  }
                                            ]
                                         }  ]
                                       ]
                                    },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "13"  }
                                       ]
                                    },
                                    {  "prim": "DUP",
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
                                                 {  "string": "permit"  }
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
                                    {  "prim": "CAR"  },
                                    {  "prim": "ITER",
                                       "args": [
                                         [  {  "prim": "DUP",
                                               "args": [
                                                 {  "int": "13"  }
                                               ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "2"  }
                                            ]
                                         },
                                         {  "prim": "GET"  },
                                         {  "prim": "IF_NONE",
                                            "args": [
                                              [  {  "prim": "PUSH",
                                                    "args": [
                                                      {  "prim": "string"  },
                                                      {  "string": "permit"  }
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
                                              {  "int": "22"  }
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "3"  }
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
                                              {  "int": "19"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "EXEC"  },
                                         {  "prim": "IF",
                                            "args": [
                                              [  {  "prim": "DUP",
                                                    "args": [
                                                      {  "int": "14"  }
                                                    ]
                                              },
                                              {  "prim": "NONE",
                                                 "args": [
                                                   {  "prim": "pair",
                                                      "args": [
                                                        {  "prim": "timestamp"  },
                                                        {  "prim": "option",
                                                           "args": [
                                                             {  "prim": "int"  }
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
                                              {  "prim": "UPDATE"  },
                                              {  "prim": "DIP",
                                                 "args": [
                                                   {  "int": "1"  },
                                                   [  {  "prim": "DIG",
                                                         "args": [
                                                           {  "int": "13"  }
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
                                                   {  "int": "13"  }
                                                 ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "15"  }
                                                 ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "16"  }
                                                 ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "7"  }
                                                 ]
                                              },
                                              {  "prim": "GET"  },
                                              {  "prim": "IF_NONE",
                                                 "args": [
                                                   [  {  "prim": "PUSH",
                                                         "args": [
                                                           {  "prim": "string"  },
                                                           {  "string": "permit"  }
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
                                              {  "prim": "UNPAIR"  },
                                              {  "prim": "DROP",
                                                 "args": [
                                                   {  "int": "1"  }
                                                 ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "17"  }
                                                 ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "8"  }
                                                 ]
                                              },
                                              {  "prim": "GET"  },
                                              {  "prim": "IF_NONE",
                                                 "args": [
                                                   [  {  "prim": "PUSH",
                                                         "args": [
                                                           {  "prim": "string"  },
                                                           {  "string": "permit"  }
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
                                              {  "prim": "CAR"  },
                                              {  "prim": "PUSH",
                                                 "args": [
                                                   {  "prim": "bool"  },
                                                   {  "prim": "False"  }
                                                 ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "6"  }
                                                 ]
                                              },
                                              {  "prim": "UPDATE"  },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "SOME"  },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "7"  }
                                                 ]
                                              },
                                              {  "prim": "UPDATE"  },
                                              {  "prim": "DIP",
                                                 "args": [
                                                   {  "int": "1"  },
                                                   [  {  "prim": "DIG",
                                                         "args": [
                                                           {  "int": "14"  }
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
                                                   {  "int": "14"  }
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
                                    {  "prim": "DROP",
                                       "args": [
                                         {  "int": "6"  }
                                       ]
                                    },
                                    {  "prim": "PAIR",
                                       "args": [
                                         {  "int": "11"  }
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
                                    {  "prim": "SELF_ADDRESS"  },
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
                                         {  "int": "16"  }
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
                                         {  "int": "5"  }
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
                                         {  "int": "11"  }
                                       ]
                                    },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "14"  }
                                       ]
                                    },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "EXEC"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "DUP",
                                               "args": [
                                                 {  "int": "9"  }
                                               ]
                                         },
                                         {  "prim": "NONE",
                                            "args": [
                                              {  "prim": "pair",
                                                 "args": [
                                                   {  "prim": "timestamp"  },
                                                   {  "prim": "option",
                                                      "args": [
                                                        {  "prim": "int"  }
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
                                         {  "prim": "UPDATE"  },
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
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "10"  }
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "11"  }
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "5"  }
                                            ]
                                         },
                                         {  "prim": "GET"  },
                                         {  "prim": "IF_NONE",
                                            "args": [
                                              [  {  "prim": "PUSH",
                                                    "args": [
                                                      {  "prim": "string"  },
                                                      {  "string": "permit"  }
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
                                         {  "prim": "UNPAIR"  },
                                         {  "prim": "DROP",
                                            "args": [
                                              {  "int": "1"  }
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "12"  }
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "6"  }
                                            ]
                                         },
                                         {  "prim": "GET"  },
                                         {  "prim": "IF_NONE",
                                            "args": [
                                              [  {  "prim": "PUSH",
                                                    "args": [
                                                      {  "prim": "string"  },
                                                      {  "string": "permit"  }
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
                                         {  "prim": "CAR"  },
                                         {  "prim": "PUSH",
                                            "args": [
                                              {  "prim": "bool"  },
                                              {  "prim": "False"  }
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "6"  }
                                            ]
                                         },
                                         {  "prim": "UPDATE"  },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "SOME"  },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "5"  }
                                            ]
                                         },
                                         {  "prim": "UPDATE"  },
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
                                         }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DROP",
                                       "args": [
                                         {  "int": "3"  }
                                       ]
                                    },
                                    {  "prim": "PAIR",
                                       "args": [
                                         {  "int": "11"  }
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
                                    [  {  "prim": "UNPAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "UNPAIR"  },
                                    {  "prim": "SWAP"  },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "13"  }
                                       ]
                                    },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "CONTRACT_PAUSED"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
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
                                    {  "prim": "MEM"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "DUP",
                                               "args": [
                                                 {  "int": "10"  }
                                               ]
                                         },
                                         {  "prim": "DUP",
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
                                                      {  "string": "permit"  }
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
                                         {  "prim": "CAR"  },
                                         {  "prim": "ITER",
                                            "args": [
                                              [  {  "prim": "DUP",
                                                    "args": [
                                                      {  "int": "10"  }
                                                    ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "2"  }
                                                 ]
                                              },
                                              {  "prim": "GET"  },
                                              {  "prim": "IF_NONE",
                                                 "args": [
                                                   [  {  "prim": "PUSH",
                                                         "args": [
                                                           {  "prim": "string"  },
                                                           {  "string": "permit"  }
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
                                                   {  "int": "19"  }
                                                 ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "3"  }
                                                 ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "13"  }
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
                                              {  "prim": "IF",
                                                 "args": [
                                                   [  {  "prim": "DUP",
                                                         "args": [
                                                           {  "int": "11"  }
                                                         ]
                                                   },
                                                   {  "prim": "NONE",
                                                      "args": [
                                                        {  "prim": "pair",
                                                           "args": [
                                                             {  "prim": "timestamp"  },
                                                             {  "prim": "option",
                                                                "args": [
                                                                  {  "prim": "int"  }
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
                                                   {  "prim": "UPDATE"  },
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
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "12"  }
                                                      ]
                                                   },
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "13"  }
                                                      ]
                                                   },
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "7"  }
                                                      ]
                                                   },
                                                   {  "prim": "GET"  },
                                                   {  "prim": "IF_NONE",
                                                      "args": [
                                                        [  {  "prim": "PUSH",
                                                              "args": [
                                                                {  "prim": "string"  },
                                                                {  "string": "permit"  }
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
                                                   {  "prim": "UNPAIR"  },
                                                   {  "prim": "DROP",
                                                      "args": [
                                                        {  "int": "1"  }
                                                      ]
                                                   },
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "14"  }
                                                      ]
                                                   },
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "8"  }
                                                      ]
                                                   },
                                                   {  "prim": "GET"  },
                                                   {  "prim": "IF_NONE",
                                                      "args": [
                                                        [  {  "prim": "PUSH",
                                                              "args": [
                                                                {  "prim": "string"  },
                                                                {  "string": "permit"  }
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
                                                   {  "prim": "CAR"  },
                                                   {  "prim": "PUSH",
                                                      "args": [
                                                        {  "prim": "bool"  },
                                                        {  "prim": "False"  }
                                                      ]
                                                   },
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "6"  }
                                                      ]
                                                   },
                                                   {  "prim": "UPDATE"  },
                                                   {  "prim": "PAIR"  },
                                                   {  "prim": "SOME"  },
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "7"  }
                                                      ]
                                                   },
                                                   {  "prim": "UPDATE"  },
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
                                         }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "12"  }
                                       ]
                                    },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "3"  }
                                       ]
                                    },
                                    {  "prim": "COMPARE"  },
                                    {  "prim": "GE"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "EXPIRY_TOO_BIG"  }
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
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "3"  }
                                       ]
                                    },
                                    {  "prim": "COMPARE"  },
                                    {  "prim": "LT"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "EXPIRY_NEGATIVE"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DUP"  },
                                    {  "prim": "IF_NONE",
                                       "args": [
                                         [  {  "prim": "DUP",
                                               "args": [
                                                 {  "int": "10"  }
                                               ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "4"  }
                                            ]
                                         },
                                         {  "prim": "MEM"  },
                                         {  "prim": "IF",
                                            "args": [
                                              [  {  "prim": "DUP",
                                                    "args": [
                                                      {  "int": "10"  }
                                                    ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "11"  }
                                                 ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "5"  }
                                                 ]
                                              },
                                              {  "prim": "GET"  },
                                              {  "prim": "IF_NONE",
                                                 "args": [
                                                   [  {  "prim": "PUSH",
                                                         "args": [
                                                           {  "prim": "string"  },
                                                           {  "string": "permit"  }
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
                                              {  "prim": "UNPAIR"  },
                                              {  "prim": "SWAP"  },
                                              {  "prim": "UNPAIR"  },
                                              {  "prim": "DROP",
                                                 "args": [
                                                   {  "int": "1"  }
                                                 ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "5"  }
                                                 ]
                                              },
                                              {  "prim": "SOME"  },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "SWAP"  },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "SOME"  },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "5"  }
                                                 ]
                                              },
                                              {  "prim": "UPDATE"  },
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
                                              }  ],
                                              [  {  "prim": "DUP",
                                                    "args": [
                                                      {  "int": "10"  }
                                                    ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "4"  }
                                                 ]
                                              },
                                              {  "prim": "MEM"  },
                                              {  "prim": "IF",
                                                 "args": [
                                                   [  {  "prim": "PUSH",
                                                         "args": [
                                                           {  "prim": "string"  },
                                                           {  "string": "permit"  }
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
                                                           {  "int": "10"  }
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
                                                        {  "int": "4"  }
                                                      ]
                                                   },
                                                   {  "prim": "SOME"  },
                                                   {  "prim": "PAIR"  },
                                                   {  "prim": "EMPTY_SET",
                                                      "args": [
                                                        {  "prim": "bytes"  }
                                                      ]
                                                   },
                                                   {  "prim": "PAIR"  },
                                                   {  "prim": "SOME"  },
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "5"  }
                                                      ]
                                                   },
                                                   {  "prim": "UPDATE"  },
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
                                                   }  ]
                                                 ]
                                              }  ]
                                            ]
                                         }  ],
                                         [  {  "prim": "SENDER"  },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "5"  }
                                            ]
                                         },
                                         {  "prim": "COMPARE"  },
                                         {  "prim": "NEQ"  },
                                         {  "prim": "IF",
                                            "args": [
                                              [  {  "prim": "PUSH",
                                                    "args": [
                                                      {  "prim": "string"  },
                                                      {  "string": "NOT_PERMIT_ISSUER"  }
                                                    ]
                                              },
                                              {  "prim": "FAILWITH"  }  ],
                                              [    ]
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "17"  }
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "19"  }
                                            ]
                                         },
                                         {  "prim": "PUSH",
                                            "args": [
                                              {  "prim": "string"  },
                                              {  "string": "PERMIT_MISSING"  }
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
                                              {  "int": "6"  }
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
                                              {  "int": "12"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "15"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "EXEC"  },
                                         {  "prim": "IF",
                                            "args": [
                                              [  {  "prim": "DUP",
                                                    "args": [
                                                      {  "int": "10"  }
                                                    ]
                                              },
                                              {  "prim": "NONE",
                                                 "args": [
                                                   {  "prim": "pair",
                                                      "args": [
                                                        {  "prim": "timestamp"  },
                                                        {  "prim": "option",
                                                           "args": [
                                                             {  "prim": "int"  }
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
                                              {  "prim": "UPDATE"  },
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
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "11"  }
                                                 ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "12"  }
                                                 ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "6"  }
                                                 ]
                                              },
                                              {  "prim": "GET"  },
                                              {  "prim": "IF_NONE",
                                                 "args": [
                                                   [  {  "prim": "PUSH",
                                                         "args": [
                                                           {  "prim": "string"  },
                                                           {  "string": "permit"  }
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
                                              {  "prim": "UNPAIR"  },
                                              {  "prim": "DROP",
                                                 "args": [
                                                   {  "int": "1"  }
                                                 ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "13"  }
                                                 ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "7"  }
                                                 ]
                                              },
                                              {  "prim": "GET"  },
                                              {  "prim": "IF_NONE",
                                                 "args": [
                                                   [  {  "prim": "PUSH",
                                                         "args": [
                                                           {  "prim": "string"  },
                                                           {  "string": "permit"  }
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
                                              {  "prim": "CAR"  },
                                              {  "prim": "PUSH",
                                                 "args": [
                                                   {  "prim": "bool"  },
                                                   {  "prim": "False"  }
                                                 ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "5"  }
                                                 ]
                                              },
                                              {  "prim": "UPDATE"  },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "SOME"  },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "6"  }
                                                 ]
                                              },
                                              {  "prim": "UPDATE"  },
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
                                              }  ],
                                              [    ]
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "11"  }
                                            ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "5"  }
                                            ]
                                         },
                                         {  "prim": "MEM"  },
                                         {  "prim": "IF",
                                            "args": [
                                              [  {  "prim": "DUP",
                                                    "args": [
                                                      {  "int": "18"  }
                                                    ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "2"  }
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
                                                   {  "int": "15"  }
                                                 ]
                                              },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "EXEC"  },
                                              {  "prim": "NOT"  },
                                              {  "prim": "IF",
                                                 "args": [
                                                   [  {  "prim": "PUSH",
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
                                                   {  "prim": "COMPARE"  },
                                                   {  "prim": "EQ"  },
                                                   {  "prim": "IF",
                                                      "args": [
                                                        [  {  "prim": "DUP",
                                                              "args": [
                                                                {  "int": "10"  }
                                                              ]
                                                        },
                                                        {  "prim": "NONE",
                                                           "args": [
                                                             {  "prim": "pair",
                                                                "args": [
                                                                  {  "prim": "timestamp"  },
                                                                  {
                                                                  "prim": "option",
                                                                  "args": [
                                                                    {  "prim": "int"  }
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
                                                        {  "prim": "UPDATE"  },
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
                                                        {  "prim": "DUP",
                                                           "args": [
                                                             {  "int": "11"  }
                                                           ]
                                                        },
                                                        {  "prim": "DUP",
                                                           "args": [
                                                             {  "int": "12"  }
                                                           ]
                                                        },
                                                        {  "prim": "DUP",
                                                           "args": [
                                                             {  "int": "6"  }
                                                           ]
                                                        },
                                                        {  "prim": "GET"  },
                                                        {  "prim": "IF_NONE",
                                                           "args": [
                                                             [  {  "prim": "PUSH",
                                                                   "args": [

                                                                   {  "prim": "string"  },
                                                                   {  "string": "permit"  }
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
                                                        {  "prim": "UNPAIR"  },
                                                        {  "prim": "DROP",
                                                           "args": [
                                                             {  "int": "1"  }
                                                           ]
                                                        },
                                                        {  "prim": "DUP",
                                                           "args": [
                                                             {  "int": "13"  }
                                                           ]
                                                        },
                                                        {  "prim": "DUP",
                                                           "args": [
                                                             {  "int": "7"  }
                                                           ]
                                                        },
                                                        {  "prim": "GET"  },
                                                        {  "prim": "IF_NONE",
                                                           "args": [
                                                             [  {  "prim": "PUSH",
                                                                   "args": [

                                                                   {  "prim": "string"  },
                                                                   {  "string": "permit"  }
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
                                                        {  "prim": "CAR"  },
                                                        {  "prim": "PUSH",
                                                           "args": [
                                                             {  "prim": "bool"  },
                                                             {  "prim": "False"  }
                                                           ]
                                                        },
                                                        {  "prim": "DUP",
                                                           "args": [
                                                             {  "int": "5"  }
                                                           ]
                                                        },
                                                        {  "prim": "UPDATE"  },
                                                        {  "prim": "PAIR"  },
                                                        {  "prim": "SOME"  },
                                                        {  "prim": "DUP",
                                                           "args": [
                                                             {  "int": "6"  }
                                                           ]
                                                        },
                                                        {  "prim": "UPDATE"  },
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
                                                        }  ],
                                                        [  {  "prim": "DUP",
                                                              "args": [
                                                                {  "int": "10"  }
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
                                                             [  {  "prim": "DUP",
                                                                   "args": [

                                                                   {  "int": "11"  }
                                                                   ]
                                                             },
                                                             {  "prim": "DUP",
                                                                "args": [
                                                                  {  "int": "5"  }
                                                                ]
                                                             },
                                                             {  "prim": "GET"  },
                                                             {  "prim": "IF_NONE",
                                                                "args": [
                                                                  [  {
                                                                  "prim": "PUSH",
                                                                  "args": [
                                                                    {  "prim": "string"  },
                                                                    {  "string": "permit"  }
                                                                  ]
                                                                  },
                                                                  {
                                                                  "prim": "PUSH",
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
                                                             {  "prim": "CAR"  },
                                                             {  "prim": "DUP",
                                                                "args": [
                                                                  {  "int": "2"  }
                                                                ]
                                                             },
                                                             {  "prim": "MEM"  },
                                                             {  "prim": "IF",
                                                                "args": [
                                                                  [  {
                                                                  "prim": "DUP",
                                                                  "args": [
                                                                    {  "int": "10"  }
                                                                  ]
                                                                  },
                                                                  {
                                                                  "prim": "DUP",
                                                                  "args": [
                                                                    {  "int": "11"  }
                                                                  ]
                                                                  },
                                                                  {
                                                                  "prim": "DUP",
                                                                  "args": [
                                                                    {  "int": "3"  }
                                                                  ]
                                                                  },
                                                                  {  "prim": "GET"  },
                                                                  {
                                                                  "prim": "IF_NONE",
                                                                  "args": [
                                                                    [  {
                                                                    "prim": "PUSH",
                                                                    "args": [

                                                                    {  "prim": "string"  },
                                                                    {  "string": "permit_info"  }
                                                                    ]
                                                                    },
                                                                    {
                                                                    "prim": "PUSH",
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
                                                                  {  "prim": "UNPAIR"  },
                                                                  {  "prim": "SWAP"  },
                                                                  {
                                                                  "prim": "DROP",
                                                                  "args": [
                                                                    {  "int": "1"  }
                                                                  ]
                                                                  },
                                                                  {
                                                                  "prim": "DUP",
                                                                  "args": [
                                                                    {  "int": "5"  }
                                                                  ]
                                                                  },
                                                                  {  "prim": "SOME"  },
                                                                  {  "prim": "SWAP"  },
                                                                  {  "prim": "PAIR"  },
                                                                  {  "prim": "SOME"  },
                                                                  {
                                                                  "prim": "DUP",
                                                                  "args": [
                                                                    {  "int": "3"  }
                                                                  ]
                                                                  },
                                                                  {  "prim": "UPDATE"  },
                                                                  {
                                                                  "prim": "DIP",
                                                                  "args": [
                                                                    {  "int": "1"  },
                                                                    [  {
                                                                    "prim": "DIG",
                                                                    "args": [

                                                                    {  "int": "9"  }
                                                                    ]
                                                                    },
                                                                    {
                                                                    "prim": "DROP",
                                                                    "args": [

                                                                    {  "int": "1"  }
                                                                    ]
                                                                    }  ]
                                                                  ]
                                                                  },
                                                                  {
                                                                  "prim": "DUG",
                                                                  "args": [
                                                                    {  "int": "9"  }
                                                                  ]
                                                                  }  ],
                                                                  [  {  "prim": "DUP"  },
                                                                  {
                                                                  "prim": "PUSH",
                                                                  "args": [
                                                                    {  "prim": "string"  },
                                                                    {  "string": "KeyNotFound"  }
                                                                  ]
                                                                  },
                                                                  {  "prim": "PAIR"  },
                                                                  {  "prim": "FAILWITH"  }  ]
                                                                ]
                                                             }  ],
                                                             [  {  "prim": "DUP",
                                                                   "args": [

                                                                   {  "int": "10"  }
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
                                                                  [  {
                                                                  "prim": "PUSH",
                                                                  "args": [
                                                                    {  "prim": "string"  },
                                                                    {  "string": "permit_info"  }
                                                                  ]
                                                                  },
                                                                  {
                                                                  "prim": "PUSH",
                                                                  "args": [
                                                                    {  "prim": "string"  },
                                                                    {  "string": "KeyExists"  }
                                                                  ]
                                                                  },
                                                                  {  "prim": "PAIR"  },
                                                                  {  "prim": "FAILWITH"  }  ],
                                                                  [  {
                                                                  "prim": "DUP",
                                                                  "args": [
                                                                    {  "int": "10"  }
                                                                  ]
                                                                  },
                                                                  {
                                                                  "prim": "DUP",
                                                                  "args": [
                                                                    {  "int": "4"  }
                                                                  ]
                                                                  },
                                                                  {  "prim": "SOME"  },
                                                                  {  "prim": "NOW"  },
                                                                  {  "prim": "PAIR"  },
                                                                  {  "prim": "SOME"  },
                                                                  {
                                                                  "prim": "DUP",
                                                                  "args": [
                                                                    {  "int": "3"  }
                                                                  ]
                                                                  },
                                                                  {  "prim": "UPDATE"  },
                                                                  {
                                                                  "prim": "DIP",
                                                                  "args": [
                                                                    {  "int": "1"  },
                                                                    [  {
                                                                    "prim": "DIG",
                                                                    "args": [

                                                                    {  "int": "9"  }
                                                                    ]
                                                                    },
                                                                    {
                                                                    "prim": "DROP",
                                                                    "args": [

                                                                    {  "int": "1"  }
                                                                    ]
                                                                    }  ]
                                                                  ]
                                                                  },
                                                                  {
                                                                  "prim": "DUG",
                                                                  "args": [
                                                                    {  "int": "9"  }
                                                                  ]
                                                                  }  ]
                                                                ]
                                                             },
                                                             {  "prim": "DUP",
                                                                "args": [
                                                                  {  "int": "11"  }
                                                                ]
                                                             },
                                                             {  "prim": "DUP",
                                                                "args": [
                                                                  {  "int": "12"  }
                                                                ]
                                                             },
                                                             {  "prim": "DUP",
                                                                "args": [
                                                                  {  "int": "6"  }
                                                                ]
                                                             },
                                                             {  "prim": "GET"  },
                                                             {  "prim": "IF_NONE",
                                                                "args": [
                                                                  [  {
                                                                  "prim": "PUSH",
                                                                  "args": [
                                                                    {  "prim": "string"  },
                                                                    {  "string": "permit"  }
                                                                  ]
                                                                  },
                                                                  {
                                                                  "prim": "PUSH",
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
                                                             {  "prim": "UNPAIR"  },
                                                             {  "prim": "DROP",
                                                                "args": [
                                                                  {  "int": "1"  }
                                                                ]
                                                             },
                                                             {  "prim": "DUP",
                                                                "args": [
                                                                  {  "int": "13"  }
                                                                ]
                                                             },
                                                             {  "prim": "DUP",
                                                                "args": [
                                                                  {  "int": "7"  }
                                                                ]
                                                             },
                                                             {  "prim": "GET"  },
                                                             {  "prim": "IF_NONE",
                                                                "args": [
                                                                  [  {
                                                                  "prim": "PUSH",
                                                                  "args": [
                                                                    {  "prim": "string"  },
                                                                    {  "string": "permit"  }
                                                                  ]
                                                                  },
                                                                  {
                                                                  "prim": "PUSH",
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
                                                             {  "prim": "CAR"  },
                                                             {  "prim": "PUSH",
                                                                "args": [
                                                                  {  "prim": "bool"  },
                                                                  {  "prim": "True"  }
                                                                ]
                                                             },
                                                             {  "prim": "DUP",
                                                                "args": [
                                                                  {  "int": "5"  }
                                                                ]
                                                             },
                                                             {  "prim": "UPDATE"  },
                                                             {  "prim": "PAIR"  },
                                                             {  "prim": "SOME"  },
                                                             {  "prim": "DUP",
                                                                "args": [
                                                                  {  "int": "6"  }
                                                                ]
                                                             },
                                                             {  "prim": "UPDATE"  },
                                                             {  "prim": "DIP",
                                                                "args": [
                                                                  {  "int": "1"  },
                                                                  [  {
                                                                  "prim": "DIG",
                                                                  "args": [
                                                                    {  "int": "10"  }
                                                                  ]
                                                                  },
                                                                  {
                                                                  "prim": "DROP",
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
                                                             }  ]
                                                           ]
                                                        }  ]
                                                      ]
                                                   }  ],
                                                   [  {  "prim": "DUP",
                                                         "args": [
                                                           {  "int": "10"  }
                                                         ]
                                                   },
                                                   {  "prim": "NONE",
                                                      "args": [
                                                        {  "prim": "pair",
                                                           "args": [
                                                             {  "prim": "timestamp"  },
                                                             {  "prim": "option",
                                                                "args": [
                                                                  {  "prim": "int"  }
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
                                                   {  "prim": "UPDATE"  },
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
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "11"  }
                                                      ]
                                                   },
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "12"  }
                                                      ]
                                                   },
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "6"  }
                                                      ]
                                                   },
                                                   {  "prim": "GET"  },
                                                   {  "prim": "IF_NONE",
                                                      "args": [
                                                        [  {  "prim": "PUSH",
                                                              "args": [
                                                                {  "prim": "string"  },
                                                                {  "string": "permit"  }
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
                                                   {  "prim": "UNPAIR"  },
                                                   {  "prim": "DROP",
                                                      "args": [
                                                        {  "int": "1"  }
                                                      ]
                                                   },
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "13"  }
                                                      ]
                                                   },
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "7"  }
                                                      ]
                                                   },
                                                   {  "prim": "GET"  },
                                                   {  "prim": "IF_NONE",
                                                      "args": [
                                                        [  {  "prim": "PUSH",
                                                              "args": [
                                                                {  "prim": "string"  },
                                                                {  "string": "permit"  }
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
                                                   {  "prim": "CAR"  },
                                                   {  "prim": "PUSH",
                                                      "args": [
                                                        {  "prim": "bool"  },
                                                        {  "prim": "False"  }
                                                      ]
                                                   },
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "5"  }
                                                      ]
                                                   },
                                                   {  "prim": "UPDATE"  },
                                                   {  "prim": "PAIR"  },
                                                   {  "prim": "SOME"  },
                                                   {  "prim": "DUP",
                                                      "args": [
                                                        {  "int": "6"  }
                                                      ]
                                                   },
                                                   {  "prim": "UPDATE"  },
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
                                                   }  ]
                                                 ]
                                              }  ],
                                              [    ]
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
                                    },
                                    {  "prim": "PAIR",
                                       "args": [
                                         {  "int": "11"  }
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
                                            {  "int": "11"  }
                                          ]
                                    },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "CONTRACT_PAUSED"  }
                                               ]
                                         },
                                         {  "prim": "FAILWITH"  }  ],
                                         [    ]
                                       ]
                                    },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "17"  }
                                       ]
                                    },
                                    {  "prim": "DUP",
                                       "args": [
                                         {  "int": "2"  }
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
                                         {  "int": "6"  }
                                       ]
                                    },
                                    {  "prim": "PAIR"  },
                                    {  "prim": "EXEC"  },
                                    {  "prim": "NOT"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "DUP",
                                               "args": [
                                                 {  "int": "16"  }
                                               ]
                                         },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "2"  }
                                            ]
                                         },
                                         {  "prim": "PUSH",
                                            "args": [
                                              {  "prim": "string"  },
                                              {  "string": "FA2_NOT_OPERATOR"  }
                                            ]
                                         },
                                         {  "prim": "PAIR"  },
                                         {  "prim": "EXEC"  },
                                         {  "prim": "IF_NONE",
                                            "args": [
                                              [    ],
                                              [  {  "prim": "DUP",
                                                    "args": [
                                                      {  "int": "14"  }
                                                    ]
                                              },
                                              {  "prim": "SELF_ADDRESS"  },
                                              {  "prim": "CONTRACT",
                                                 "args": [
                                                   {  "prim": "pair",
                                                      "args": [
                                                        {  "prim": "address"  },
                                                        {  "prim": "pair",
                                                           "args": [
                                                             {  "prim": "bytes"  },
                                                             {  "prim": "string"  }
                                                           ]
                                                        }
                                                      ]
                                                   }
                                                 ]
                                                 ,
                                                 "annots": [
                                                   "%consumePermit"
                                                 ]
                                              },
                                              {  "prim": "IF_NONE",
                                                 "args": [
                                                   [  {  "prim": "PUSH",
                                                         "args": [
                                                           {  "prim": "string"  },
                                                           {  "string": "consumePermit"  }
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
                                              {  "prim": "PUSH",
                                                 "args": [
                                                   {  "prim": "string"  },
                                                   {  "string": "FA2_NOT_OPERATOR"  }
                                                 ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "6"  }
                                                 ]
                                              },
                                              {  "prim": "PACK"  },
                                              {  "prim": "BLAKE2B"  },
                                              {  "prim": "PAIR"  },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "5"  }
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
                                                           {  "int": "13"  }
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
                                                   {  "int": "13"  }
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
                                    {  "prim": "DUP"  },
                                    {  "prim": "ITER",
                                       "args": [
                                         [  {  "prim": "DUP"  },
                                         {  "prim": "CAR"  },
                                         {  "prim": "DUP",
                                            "args": [
                                              {  "int": "2"  }
                                            ]
                                         },
                                         {  "prim": "CDR"  },
                                         {  "prim": "DUP"  },
                                         {  "prim": "ITER",
                                            "args": [
                                              [  {  "prim": "PUSH",
                                                    "args": [
                                                      {  "prim": "nat"  },
                                                      {  "int": "1"  }
                                                    ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "2"  }
                                                 ]
                                              },
                                              {  "prim": "CDR"  },
                                              {  "prim": "CDR"  },
                                              {  "prim": "COMPARE"  },
                                              {  "prim": "EQ"  },
                                              {  "prim": "NOT"  },
                                              {  "prim": "IF",
                                                 "args": [
                                                   [  {  "prim": "PUSH",
                                                         "args": [
                                                           {  "prim": "string"  },
                                                           {  "string": "FA2_INSUFFICIENT_BALANCE"  }
                                                         ]
                                                   },
                                                   {  "prim": "FAILWITH"  }  ],
                                                   [    ]
                                                 ]
                                              },
                                              {  "prim": "DUP"  },
                                              {  "prim": "CDR"  },
                                              {  "prim": "CAR"  },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "9"  }
                                                 ]
                                              },
                                              {  "prim": "DUP",
                                                 "args": [
                                                   {  "int": "3"  }
                                                 ]
                                              },
                                              {  "prim": "CAR"  },
                                              {  "prim": "SOME"  },
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
                                                   {  "int": "2"  }
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
                                    },
                                    {  "prim": "PAIR",
                                       "args": [
                                         {  "int": "11"  }
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
                                    {  "prim": "PAIR",
                                       "args": [
                                         {  "int": "11"  }
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
                                    {  "prim": "SELF_ADDRESS"  },
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
                                         {  "int": "12"  }
                                       ]
                                    },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "CONTRACT_PAUSED"  }
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
                                         {  "int": "3"  }
                                       ]
                                    },
                                    {  "prim": "MEM"  },
                                    {  "prim": "IF",
                                       "args": [
                                         [  {  "prim": "PUSH",
                                               "args": [
                                                 {  "prim": "string"  },
                                                 {  "string": "royalties"  }
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
                                                 {  "int": "4"  }
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
                                    {  "prim": "PAIR",
                                       "args": [
                                         {  "int": "11"  }
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
                                 {  "int": "14"  }
                               ]
                            },
                            {  "prim": "IF",
                               "args": [
                                 [  {  "prim": "PUSH",
                                       "args": [
                                         {  "prim": "string"  },
                                         {  "string": "CONTRACT_PAUSED"  }
                                       ]
                                 },
                                 {  "prim": "FAILWITH"  }  ],
                                 [    ]
                               ]
                            },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "16"  }
                               ]
                            },
                            {  "prim": "SELF_ADDRESS"  },
                            {  "prim": "CONTRACT",
                               "args": [
                                 {  "prim": "pair",
                                    "args": [
                                      {  "prim": "nat"  },
                                      {  "prim": "map",
                                         "args": [
                                           {  "prim": "string"  },
                                           {  "prim": "bytes"  }
                                         ]
                                      }
                                    ]
                                 }
                               ]
                               ,
                               "annots": [
                                 "%setTokenMetadata"
                               ]
                            },
                            {  "prim": "IF_NONE",
                               "args": [
                                 [  {  "prim": "PUSH",
                                       "args": [
                                         {  "prim": "string"  },
                                         {  "string": "setTokenMetadata"  }
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
                                 {  "int": "5"  }
                               ]
                            },
                            {  "prim": "DUP",
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
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "16"  }
                               ]
                            },
                            {  "prim": "SELF_ADDRESS"  },
                            {  "prim": "CONTRACT",
                               "args": [
                                 {  "prim": "pair",
                                    "args": [
                                      {  "prim": "nat"  },
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
                               ,
                               "annots": [
                                 "%setRoyalties"
                               ]
                            },
                            {  "prim": "IF_NONE",
                               "args": [
                                 [  {  "prim": "PUSH",
                                       "args": [
                                         {  "prim": "string"  },
                                         {  "string": "setRoyalties"  }
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
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "7"  }
                               ]
                            },
                            {  "prim": "DUP",
                               "args": [
                                 {  "int": "5"  }
                               ]
                            },
                            {  "prim": "MEM"  },
                            {  "prim": "IF",
                               "args": [
                                 [  {  "prim": "PUSH",
                                       "args": [
                                         {  "prim": "string"  },
                                         {  "string": "ledger"  }
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
                                 {  "prim": "DUP",
                                    "args": [
                                      {  "int": "4"  }
                                    ]
                                 },
                                 {  "prim": "SOME"  },
                                 {  "prim": "DUP",
                                    "args": [
                                      {  "int": "6"  }
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
                            {  "prim": "DROP",
                               "args": [
                                 {  "int": "4"  }
                               ]
                            },
                            {  "prim": "PAIR",
                               "args": [
                                 {  "int": "11"  }
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
            }  ]
          ]
       },
       {  "prim": "DIP",
          "args": [
            {  "int": "1"  },
            [  {  "prim": "DROP",
                  "args": [
                    {  "int": "4"  }
                  ]
            }  ]
          ]
       }  ]
     ]
  }  ]

export function nft_public_storage(owner : string) : any {
  return {  "prim": "Pair",
            "args": [
              {  "string": owner  },
              {  "prim": "Pair",
                 "args": [
                   [    ],
                   {  "prim": "Pair",
                      "args": [
                        [    ],
                        {  "prim": "Pair",
                           "args": [
                             [    ],
                             {  "prim": "Pair",
                                "args": [
                                  [    ],
                                  {  "prim": "Pair",
                                     "args": [
                                       [    ],
                                       {  "prim": "Pair",
                                          "args": [
                                            [    ],
                                            {  "prim": "Pair",
                                               "args": [
                                                 [    ],
                                                 {  "prim": "Pair",
                                                    "args": [
                                                      {  "int": "31536000000"  },
                                                      {  "prim": "Pair",
                                                         "args": [
                                                           {  "prim": "False"  },
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
                           ]
                        }
                      ]
                   }
                 ]
              }
            ]
         }
}

export async function deploy_nft_public(
  provider : Provider,
  owner: string,
) : Promise<OperationResult> {
  const init = nft_public_storage(owner)
  return provider.tezos.originate({init, code: nft_public_code})
}
