open Projeto_etl_lib.Io
open Projeto_etl_lib.Transforms

let () =
  
  let url_order = "http://127.0.0.1:5000/order" in
  let url_items = "http://127.0.0.1:5000/order_item" in
  let content_order = fetch_content_from_http url_order in
  let content_items = fetch_content_from_http url_items in

  (* 1. Captura de Parâmetros*) 
  let status_input = prompt_input "Caso deseje filtrar por status digite: complete, pending ou cancelled. Caso o input seja vazio ou nenhuma das opções não irá haver filtragem:"  in
  let status_filter = input_status status_input in

  let origin_input = prompt_input "Caso deseje filtrar por origem digite: o ou p. Caso o input seja vazio ou nenhuma das opções não irá haver filtragem:"in
  let origin_filter = input_origin origin_input in

  (* 2. Captura de Dados *)
  let orders_data = read_csv content_order in
  let items_data = read_csv content_items in

  (* 3. Conversão dos dados para records*)
  let orders = load_orders_csv orders_data in
  let order_items = load_order_items_csv items_data in

  let orders_filtered = filter_orders orders ~status:status_filter ~origin:origin_filter in
  let joined_data = join_data orders_filtered order_items in
  let result = merge_amount_taxes joined_data in
  List.iter (fun (order_id, amount, tax) ->
    Printf.printf "Order ID: %d | Amount: %.2f | Total Tax: %.2f\n" order_id amount tax
  ) result
  
