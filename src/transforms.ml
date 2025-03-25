(** Importa o arquivo [Types]. *)
open Types
let filter_orders (orders : order list) ~(status : string option) ~(origin : string option) : order list =
  List.filter ( fun ord ->
    let status_value =
      match status with
      | None -> true
      | Some stat -> String.equal stat (ord.status|> String.trim |> String.lowercase_ascii ) 
    in
    let origin_value =
      match origin with
      | None -> true
      | Some ori -> String.equal ori (ord.origin|> String.trim |> String.lowercase_ascii ) 
    in
    status_value && origin_value
  )  orders


let join_data (orders : order list) (items : order_item list) : (order * order_item list) list =
  List.map (fun ord ->
    let joined_items = List.filter ( fun it -> it.order_id = ord.id) items in
    (ord, joined_items)
  ) orders


let merge_amount_taxes (data : (order * order_item list) list) : (int * float * float) list =
  List.map(fun dt ->
    let ord, items = dt in
    let amount, tax = List.fold_left( fun (amt, tax) item->
      let gross_profit = item.price *. item.quantity in
      let liquid_profit = gross_profit *. item.tax in
      (amt +. liquid_profit, tax +. item.tax)

    ) (0.0,0.0) items in
    (ord.id, amount, tax)

  ) data