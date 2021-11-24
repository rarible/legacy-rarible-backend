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
                                   {  "prim": "option",
                                      "args": [
                                        {  "prim": "nat"  }
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
                 {  "prim": "address",
                    "annots": [
                      "%transferOwnership"
                    ]
                 },
                 {  "prim": "unit",
                    "annots": [
                      "%claimOwnership"
                    ]
                 }
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
                      {  "prim": "option",
                         "args": [
                           {  "prim": "nat"  }
                         ]
                         ,
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
  },
  {  "prim": "code",
     "args": [
       [  {  "prim": "UNPAIR"  },
       {  "prim": "DIP",
          "args": [
            {  "int": "1"  },
            [  {  "prim": "UNPAIR",
                  "args": [
                    {  "int": "4"  }
                  ]
            }  ]
          ]
       },
       {  "prim": "IF_LEFT",
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
                    {  "prim": "PAIR",
                       "args": [
                         {  "int": "4"  }
                       ]
                    },
                    {  "prim": "NIL",
                       "args": [
                         {  "prim": "operation"  }
                       ]
                    },
                    {  "prim": "PAIR"  }  ],
                    [  {  "prim": "DROP",
                          "args": [
                            {  "int": "1"  }
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
                    {  "prim": "PAIR",
                       "args": [
                         {  "int": "4"  }
                       ]
                    },
                    {  "prim": "NIL",
                       "args": [
                         {  "prim": "operation"  }
                       ]
                    },
                    {  "prim": "PAIR"  }  ]
                  ]
            }  ],
            [  {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
            {  "prim": "UNPAIR"  },
            {  "prim": "SWAP"  },
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
            {  "prim": "DUP",
               "args": [
                 {  "int": "5"  }
               ]
            },
            {  "prim": "PAIR"  },
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
                      {  "int": "2"  }
                    ]
                 },
                 {  "prim": "SOME"  },
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "4"  }
                    ]
                 },
                 {  "prim": "DUP",
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
                 {  "prim": "DUP",
                    "args": [
                      {  "int": "5"  }
                    ]
                 },
                 {  "prim": "PAIR"  },
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
                              {  "int": "7"  }
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
                      {  "prim": "DUP",
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
                 {  "int": "3"  }
               ]
            },
            {  "prim": "PAIR",
               "args": [
                 {  "int": "4"  }
               ]
            },
            {  "prim": "NIL",
               "args": [
                 {  "prim": "operation"  }
               ]
            },
            {  "prim": "PAIR"  }  ]
          ]
       }  ]
     ]
  }  ]

export function royalties_storage(owner: string) : any {
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
