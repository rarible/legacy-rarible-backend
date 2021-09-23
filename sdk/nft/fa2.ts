export const code : any =
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
                         "%royaltiesContract"
                       ]
                    },
                    {  "prim": "pair",
                       "args": [
                         {  "prim": "big_map",
                            "args": [
                              {  "prim": "pair",
                                 "args": [
                                   {  "prim": "nat"  },
                                   {  "prim": "address"  }
                                 ]
                              },
                              {  "prim": "nat"  }
                            ]
                            ,
                            "annots": [
                              "%ledger"
                            ]
                         },
                         {  "prim": "pair",
                            "args": [
                              {  "prim": "set",
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
                                   }
                                 ]
                                 ,
                                 "annots": [
                                   "%operator"
                                 ]
                              },
                              {  "prim": "pair",
                                 "args": [
                                   {  "prim": "set",
                                      "args": [
                                        {  "prim": "pair",
                                           "args": [
                                             {  "prim": "address"  },
                                             {  "prim": "address"  }
                                           ]
                                        }
                                      ]
                                      ,
                                      "annots": [
                                        "%operator_for_all"
                                      ]
                                   },
                                   {  "prim": "pair",
                                      "args": [
                                        {  "prim": "big_map",
                                           "args": [
                                             {  "prim": "nat"  },
                                             {  "prim": "map",
                                                "args": [
                                                  {  "prim": "string"  },
                                                  {  "prim": "string"  }
                                                ]
                                             }
                                           ]
                                           ,
                                           "annots": [
                                             "%token_metadata"
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
                      }
                    ]
                 },
                 {  "prim": "or",
                    "args": [
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
                                     {  "prim": "nat",
                                        "annots": [
                                          "%iamount"
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
                                          "%royalties"
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
                                {  "prim": "nat",
                                   "annots": [
                                     "%iamount"
                                   ]
                                }
                              ]
                           }
                         ]
                         ,
                         "annots": [
                           "%burn"
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
                                {  "prim": "string"  }
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
                            [  {  "prim": "UNPAIR"  },
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
                                 {  "int": "2"  }
                               ]
                            },
                            {  "prim": "DUP"  },
                            {  "prim": "DUG",
                               "args": [
                                 {  "int": "3"  }
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
                            {  "prim": "MAP",
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
                                 {  "prim": "PAIR"  },
                                 {  "prim": "MEM"  },
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
                                      {  "prim": "PAIR"  },
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
                                      }  ],
                                      [  {  "prim": "PUSH",
                                            "args": [
                                              {  "prim": "nat"  },
                                              {  "int": "0"  }
                                            ]
                                      }  ]
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
                            [  {  "prim": "DUP"  },
                            {  "prim": "ITER",
                               "args": [
                                 [  {  "prim": "DUP"  },
                                 {  "prim": "IF_LEFT",
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
                                      {  "prim": "SOURCE"  },
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
                                      {  "prim": "PAIR"  },
                                      {  "prim": "MEM"  },
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
                                           {  "int": "2"  }
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
                                      {  "prim": "CAR",
                                         "args": [
                                           {  "int": "0"  }
                                         ]
                                      },
                                      {  "prim": "PAIR"  },
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
                                                   {  "int": "6"  }
                                                 ]
                                           },
                                           {  "prim": "DUP"  },
                                           {  "prim": "DUG",
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
                                                {  "int": "2"  }
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
                                           {  "prim": "CDR",
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
                                      {  "prim": "SOURCE"  },
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
                                      {  "prim": "PAIR"  },
                                      {  "prim": "MEM"  },
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
                                      {  "prim": "PUSH",
                                         "args": [
                                           {  "prim": "bool"  },
                                           {  "prim": "False"  }
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
                                           {  "int": "2"  }
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
                                      {  "prim": "CDR",
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
                            [  {  "prim": "DUP"  },
                            {  "prim": "ITER",
                               "args": [
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
                                      {  "prim": "SOURCE"  },
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
                                                   {  "int": "5"  }
                                                 ]
                                           },
                                           {  "prim": "DUP"  },
                                           {  "prim": "DUG",
                                              "args": [
                                                {  "int": "6"  }
                                              ]
                                           },
                                           {  "prim": "PUSH",
                                              "args": [
                                                {  "prim": "bool"  },
                                                {  "prim": "True"  }
                                              ]
                                           },
                                           {  "prim": "SOURCE"  },
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
                                           }  ]
                                         ]
                                      },
                                      {  "prim": "DROP",
                                         "args": [
                                           {  "int": "1"  }
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
                                      {  "prim": "PUSH",
                                         "args": [
                                           {  "prim": "bool"  },
                                           {  "prim": "False"  }
                                         ]
                                      },
                                      {  "prim": "SOURCE"  },
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
                            [  {  "prim": "DUP"  },
                            {  "prim": "ITER",
                               "args": [
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
                                 {  "prim": "DUP"  },
                                 {  "prim": "ITER",
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
                                      {  "prim": "SENDER"  },
                                      {  "prim": "COMPARE"  },
                                      {  "prim": "NEQ"  },
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
                                           {  "prim": "PAIR"  },
                                           {  "prim": "MEM"  },
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
                                           {  "prim": "CAR",
                                              "args": [
                                                {  "int": "0"  }
                                              ]
                                           },
                                           {  "prim": "PAIR"  },
                                           {  "prim": "SENDER"  },
                                           {  "prim": "PAIR"  },
                                           {  "prim": "MEM"  },
                                           {  "prim": "OR"  },
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
                                           }  ],
                                           [    ]
                                         ]
                                      },
                                      {  "prim": "DUP"  },
                                      {  "prim": "CDR",
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
                                      {  "prim": "PAIR"  },
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
                                      {  "prim": "CDR",
                                         "args": [
                                           {  "int": "2"  }
                                         ]
                                      },
                                      {  "prim": "COMPARE"  },
                                      {  "prim": "GT"  },
                                      {  "prim": "IF",
                                         "args": [
                                           [  {  "prim": "PUSH",
                                                 "args": [
                                                   {  "prim": "string"  },
                                                   {  "string": "FA2_INSUFFICIENT_BALANCE"  }
                                                 ]
                                           },
                                           {  "prim": "FAILWITH"  }  ],
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
                                           {  "prim": "CDR",
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
                                                        {  "int": "11"  }
                                                      ]
                                                },
                                                {  "prim": "DUP"  },
                                                {  "prim": "DUG",
                                                   "args": [
                                                     {  "int": "12"  }
                                                   ]
                                                },
                                                {  "prim": "NONE",
                                                   "args": [
                                                     {  "prim": "nat"  }
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
                                                [  {  "prim": "DIG",
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
                                                     {  "int": "12"  }
                                                   ]
                                                },
                                                {  "prim": "DUP"  },
                                                {  "prim": "DUG",
                                                   "args": [
                                                     {  "int": "13"  }
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
                                                     {  "int": "2"  }
                                                   ]
                                                },
                                                {  "prim": "INT"  },
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
                                                {  "prim": "COMPARE"  },
                                                {  "prim": "GE"  },
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
                                                     {  "prim": "CDR",
                                                        "args": [
                                                          {  "int": "2"  }
                                                        ]
                                                     },
                                                     {  "prim": "INT"  },
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
                                                     {  "prim": "SUB"  },
                                                     {  "prim": "ABS"  }  ],
                                                     [  {  "prim": "PUSH",
                                                           "args": [
                                                             {  "prim": "string"  },
                                                             {  "string": "NatAssign"  }
                                                           ]
                                                     },
                                                     {  "prim": "FAILWITH"  }  ]
                                                   ]
                                                },
                                                {  "prim": "SOME"  },
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
                                                },
                                                {  "prim": "DROP",
                                                   "args": [
                                                     {  "int": "1"  }
                                                   ]
                                                }  ]
                                              ]
                                           }  ]
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
                                      {  "prim": "MEM"  },
                                      {  "prim": "IF",
                                         "args": [
                                           [  {  "prim": "DIG",
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
                                           {  "prim": "PAIR"  },
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
                                           },
                                           {  "prim": "DROP",
                                              "args": [
                                                {  "int": "1"  }
                                              ]
                                           }  ],
                                           [  {  "prim": "DIG",
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
                                                     {  "int": "2"  }
                                                   ]
                                                },
                                                {  "prim": "PUSH",
                                                   "args": [
                                                     {  "prim": "nat"  },
                                                     {  "int": "0"  }
                                                   ]
                                                },
                                                {  "prim": "ADD"  },
                                                {  "prim": "SOME"  },
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
                            [  {  "prim": "UNPAIR"  },
                            {  "prim": "SWAP"  },
                            {  "prim": "UNPAIR"  },
                            {  "prim": "SWAP"  },
                            {  "prim": "UNPAIR"  },
                            {  "prim": "SWAP"  },
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
                                 {  "int": "10"  }
                               ]
                            },
                            {  "prim": "DUP"  },
                            {  "prim": "DUG",
                               "args": [
                                 {  "int": "11"  }
                               ]
                            },
                            {  "prim": "CONTRACT",
                               "args": [
                                 {  "prim": "pair",
                                    "args": [
                                      {  "prim": "address"  },
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
                            {  "prim": "SELF"  },
                            {  "prim": "ADDRESS"  },
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
                                 {  "prim": "SOME"  },
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
                                 }  ]
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
                            {  "prim": "PAIR"  }  ],
                            [  {  "prim": "UNPAIR"  },
                            {  "prim": "SWAP"  },
                            {  "prim": "UNPAIR"  },
                            {  "prim": "SWAP"  },
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
                            {  "prim": "DUP"  },
                            {  "prim": "DUG",
                               "args": [
                                 {  "int": "8"  }
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
                            {  "prim": "COMPARE"  },
                            {  "prim": "GT"  },
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
                                      {  "int": "9"  }
                                    ]
                                 },
                                 {  "prim": "DUP"  },
                                 {  "prim": "DUG",
                                    "args": [
                                      {  "int": "10"  }
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
                                 {  "prim": "INT"  },
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
                                 {  "prim": "COMPARE"  },
                                 {  "prim": "GE"  },
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
                                      {  "prim": "INT"  },
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
                                      {  "prim": "SUB"  },
                                      {  "prim": "ABS"  }  ],
                                      [  {  "prim": "PUSH",
                                            "args": [
                                              {  "prim": "string"  },
                                              {  "string": "NatAssign"  }
                                            ]
                                      },
                                      {  "prim": "FAILWITH"  }  ]
                                    ]
                                 },
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
                                 {  "prim": "DROP",
                                    "args": [
                                      {  "int": "1"  }
                                    ]
                                 }  ],
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
                                      {  "prim": "NONE",
                                         "args": [
                                           {  "prim": "nat"  }
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
                                      }  ],
                                      [  {  "prim": "PUSH",
                                            "args": [
                                              {  "prim": "string"  },
                                              {  "string": "FA2_INSUFFICIENT_BALANCE"  }
                                            ]
                                      },
                                      {  "prim": "FAILWITH"  }  ]
                                    ]
                                 }  ]
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
            }  ]
          ]
       }  ]
     ]
  }  ];

export function make_storage(owner: string, royaltiesContract: string) : any {
  return {  "prim": "Pair",
            "args": [
              {  "string": owner  },
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
