(** An IO module Mehari implementation for Unix and Windows using Lwt. Contains
    also extra features based on Unix filesystem such as {!section-cgi}. *)

(** {1 IO} *)

include Mehari.NET with module IO = Lwt and type addr = Ipaddr.t

(** {1 Response} *)

val respond_document : ?mime:Mehari.mime -> string -> Mehari.response Lwt.t
(** Same as {!val:respond} but respond with content of given [filename]
    and use given {!type:Mehari.mime} as mime type.
    If [filename] is not present on filesystem, responds with
    {!val:Mehari.not_found}. {!type:Mehari.mime} type is chosen
    according to the filename extension by default. If mime type inference
    failed, it uses [text/gemini; charset=utf-8]. *)

(** {1 Mime} *)

val from_filename :
  ?lookup:[ `Ext | `Content | `Both ] ->
  ?charset:string ->
  ?lang:string list ->
  string ->
  Mehari.mime Lwt.t
(** [from_filename ?lookup_into ?charset ?lang fname] creates a
    {!type:Mehari.mime} type by performing a mime lookup depending of the
    value of [lookup]:
    - [`Ext]: performs a lookup based on file extension of [fname];
    - [`Content]: performs a lookup based on content of [fname];
    - [`Both]: performs successivly a lookup on content and extension.

    Returns [make_mime ?charset ?lang "text/gemini"] if one of the previous
    lookup fails.

    @raise Unix.Unix_error if a lookup based on content is performed and
      reading of [fname] fails *)

(** {1:cgi Cgi} *)

(** Mehari supports CGI scripting as described in RFC 3875

    The CGI script must write the gemini response to the stdout stream. Status
    code and meta string on the first line, and the optional response body on
    subsequent lines. The bytes generated by the CGI script will be forwarded
    verbatim to the Gemini client, without any additional modification by the
    server.

    @see < https://www.rfc-editor.org/rfc/rfc3875 > For the CGI
      specification. *)

val run_cgi :
  ?timeout:float ->
  ?nph:bool ->
  string ->
  addr Mehari.request ->
  Mehari.response Lwt.t
(** [run_cgi ?timeout ?nph script_path req] executes the given file as a CGI
    script and return a {!type:Mehari.response} based on bytes printed on
    stdout by script. Responds with {!val:Mehari.cgi_error} in case
    of error or [timeout] exceeding.

    [timeout] defaults to [5.0].
    [nph] decides if NPH (Non-Parsed Header) is enable. Defaults to [false]. *)

(** {1 Entry point} *)

val run_lwt :
  ?port:int ->
  ?certchains:(string * string) list ->
  ?v4:string ->
  ?v6:string ->
  handler ->
  unit Lwt.t
(** See {!val:Mehari_mirage.S.run}. *)

val run :
  ?port:int ->
  ?certchains:(string * string) list ->
  ?v4:string ->
  ?v6:string ->
  handler ->
  unit
(** Like {!val:run_lwt} but calls [Lwt_main.run] internally. *)
