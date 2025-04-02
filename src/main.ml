(** Importa as funções puras [Pure] e impuras[Impure] *)
open Projeto_etl_lib.Pure
open Projeto_etl_lib.Impure

let () =
  (* 1. extração de dados*) 
  let url_order = "http://127.0.0.1:5000/order" in
  let url_items = "http://127.0.0.1:5000/order_item" in
  let content_order = fetch_content_from_http url_order in
  let content_items = fetch_content_from_http url_items in
  let orders_data = read_csv content_order in
  let items_data = read_csv content_items in
  (* 2. extração de parâmetros*) 
  let status_input = prompt_input "Caso deseje filtrar por status digite: complete, pending ou cancelled. Caso o input seja vazio ou nenhuma das opções não irá haver filtragem:"  in
  let status_filter = input_status status_input in
  let origin_input = prompt_input "Caso deseje filtrar por origem digite: o ou p. Caso o input seja vazio ou nenhuma das opções não irá haver filtragem:"in
  let origin_filter = input_origin origin_input in
  (* 3. conversão dos dados para records*)
  let orders = load_orders_csv orders_data in
  let order_items = load_order_items_csv items_data in
  (* 4. transformação dos dados*)
  let orders_filtered = filter_orders orders ~status:status_filter ~origin:origin_filter in
  let joined_data = join_data orders_filtered order_items in
  let result_revenue_tax = merge_amount_taxes joined_data in
  let mean_months = dates_mean joined_data 7 in
  let mean_year = dates_mean joined_data 4 in
  (* 5. armazentamento dos dados*)
  let database = Sqlite3.db_open "etl.db" in
  ignore (load_total_revenue_tax database result_revenue_tax);
  ignore (load_months database mean_months);
  ignore (load_years database mean_year);
  ignore(Sqlite3.db_close database);
  (* 6. salvando resultados em CSV *)
  write_result_revenue_tax_to_csv "csv_out/result_revenue_tax.csv" result_revenue_tax;
  write_dates_mean_to_csv "csv_out/mean_months.csv" mean_months;
  write_dates_mean_to_csv "csv_out/mean_years.csv" mean_year;
  
