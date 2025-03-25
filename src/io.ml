(** Importa o arquivo [Types]. *)
open Types


(** 
  Lê um arquivo CSV e retorna todas as linhas, exceto o cabeçalho.
  @param filename Nome do arquivo CSV a ser lido.
  @return Todas as linhas do CSV sem o cabeçalho.
*)
let read_csv (content: string) : string list list =
  let csv_enum = Csv.of_string content in
  let all_rows = Csv.input_all csv_enum in
  List.tl all_rows
  
(** 
  Converte os dados do CSV em uma lista de registros do tipo {!order}.
  @param csv_data Lista de Linhas do CSV
  @return Todas as encomendas.
*)
let load_orders_csv (csv_data: string list list) : order list =
  List.map (fun row -> order_of_csv_row row) csv_data

(** 
  Converte os dados do CSV em uma lista de registros do tipo {!order_item}
  @param csv_data Lista de Linhas do CSV
  @return Todos os itens das encomendas
*)
let load_order_items_csv (csv_data: string list list) : order_item list =
  List.map (fun row -> order_item_of_csv_row row) csv_data

(** 
  Exibe a mensagem recebida no terminal e armazena o input do usuário normalizado em uma string
  @param message Mensagem a ser exibida no terminal
  @return Resposta do usuário
*)
let prompt_input (message : string) : string =
  print_string message;
  flush stdout;
  read_line ()|> String.trim |> String.lowercase_ascii 

(** 
  Atribui o tipo de status a ser filtrado
  @param status String com o tipo de filtragem de status
  @return String caso o tipo de  filtragrem esteja entre uma das opções, Vazio caso contrário
*)
let input_status (status : string) : string option  = 
  match  status with
  |"complete" | "pending" | "cancelled" -> Some status
  | _ -> None

(** 
  Atribui o tipo de origem a ser filtrada
  @param status String com o tipo de filtragem de origem
  @return String caso o tipo de filtragrem esteja entre uma das opções, Vazio caso contrário
*)
let input_origin (origin : string) : string option  = 
  match origin with
  |"o"|"p" -> Some origin
  | _ -> None


let fetch_content_from_http (url : string) : string =
  let buffer = Buffer.create 16384 in
  let connection = Curl.init () in
  Curl.set_url connection url;
  Curl.set_writefunction connection
  (fun data ->
    Buffer.add_string buffer data;
    String.length data
  );
  Curl.perform connection;
  Curl.cleanup connection;
  Buffer.contents buffer
  