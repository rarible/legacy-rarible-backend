import { Provider, OperationResult } from "../common/base"

export const royalties_code : any =
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
                         {  "prim": "set",
                            "args": [
                              {  "prim": "address"  }
                            ]
                            ,
                            "annots": [
                              "%whitelist"
                            ]
                         },
                         {  "prim": "big_map",
                            "args": [
                              {  "prim": "pair",
                                 "args": [
                                   {  "prim": "address"  },
                                   {  "prim": "nat"  }
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
                           {  "prim": "address",
                              "annots": [
                                "%token"
                              ]
                           },
                           {  "prim": "pair",
                              "args": [
                                {  "prim": "nat",
                                   "annots": [
                                     "%tokenId"
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
                      },
                      {  "prim": "contract",
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
                                },
                                {  "prim": "bytes"  }
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
                 {  "prim": "pair",
                    "args": [
                      {  "prim": "address",
                         "annots": [
                           "%token"
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
                      }
                    ]
                    ,
                    "annots": [
                      "%setRoyalties"
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
                         {  "int": "4"  }
                       ]
                    },
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

export function royalties_storage(owner : string) : any {
  return {  "prim": "Pair",
            "args": [
              {  "string": owner  },
              {  "prim": "Pair",
                 "args": [
                   {  "prim": "None"  },
                   {  "prim": "Pair",
                      "args": [
                        [    ],
                        [    ]
                      ]
                   }
                 ]
              }
            ]
         }
}

export async function deploy_royalties(
  provider : Provider,
  owner: string,
) : Promise<OperationResult> {
  const init = royalties_storage(owner)
  return provider.tezos.originate({init, code: royalties_code})
}
