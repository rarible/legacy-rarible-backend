import { Provider, OperationResult } from "../common/base"

export const fill_code : any =
  [  {  "prim": "storage",
        "args": [
          {  "prim": "pair",
             "args": [
               {  "prim": "address",
                  "annots": [
                    "%admin"
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
                         {  "prim": "bytes"  },
                         {  "prim": "nat"  }
                       ]
                       ,
                       "annots": [
                         "%fill"
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
                      "%setValidator"
                    ]
                 },
                 {  "prim": "bytes",
                    "annots": [
                      "%remove"
                    ]
                 }
               ]
            },
            {  "prim": "pair",
               "args": [
                 {  "prim": "bytes",
                    "annots": [
                      "%k"
                    ]
                 },
                 {  "prim": "nat",
                    "annots": [
                      "%v"
                    ]
                 }
               ]
               ,
               "annots": [
                 "%put"
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
                    {  "int": "3"  }
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
                         {  "int": "3"  }
                       ]
                    },
                    {  "prim": "NIL",
                       "args": [
                         {  "prim": "operation"  }
                       ]
                    },
                    {  "prim": "PAIR"  }  ],
                    [  {  "prim": "DUP",
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
                         {  "int": "3"  }
                       ]
                    },
                    {  "prim": "NONE",
                       "args": [
                         {  "prim": "nat"  }
                       ]
                    },
                    {  "prim": "DUP",
                       "args": [
                         {  "int": "3"  }
                       ]
                    },
                    {  "prim": "UPDATE"  },
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
                         {  "int": "3"  }
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
            {  "prim": "DUP",
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
            {  "prim": "PAIR",
               "args": [
                 {  "int": "3"  }
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

export function fill_storage(admin: string, validator?: string) : any {
  return {  "prim": "Pair",
            "args": [
              {  "string": admin  },
              {  "prim": "Pair",
                 "args": [
                   (validator) ? {"prim": "Some", "args": [validator]} : {"prim": "None"},
                   [    ]
                 ]
              }
            ]
         }
}

export async function deploy_fill(
  provider : Provider,
  admin: string,
  validator?: string,
) : Promise<OperationResult> {
  const init = fill_storage(admin, validator)
  return provider.tezos.originate({init, code: fill_code})
}
