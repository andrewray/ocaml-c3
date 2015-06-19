class type global = object
  method runC3 : (unit -> unit) Js.prop
end

let div_id = 
  let cnt = ref 0 in
  (fun () -> 
    let id = "__c3_iocaml_div_id_" ^ string_of_int !cnt in
    incr cnt;
    id)

let install f = 
  let id = div_id () in
  (Js.Unsafe.global : global Js.t)##runC3 <- (fun () -> ignore (f ("#"^id)));
  Iocaml.display "text/html" 
    ("<div id=\"" ^ id ^ "\"></div>
     <script>window.runC3()</script>")

let render_pie_t t = install (fun bindto -> C3.Pie.render ~bindto t)
let render_gauge_t t = install (fun bindto -> C3.Gauge.render ~bindto t)
let render_line_t t = install (fun bindto -> C3.Line.render ~bindto t)

let render_line t = 
  (* insert the div *)
  let id = div_id () in
  Iocaml.display "text/html" ("<div id=\"" ^ id ^ "\"></div>");
  C3.Line.render ~bindto:("#"^id) t

