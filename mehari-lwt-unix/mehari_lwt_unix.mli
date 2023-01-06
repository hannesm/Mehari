(** An IO module Mehari implementation for Unix and Windows using Lwt. Contains
    also extra features based on Unix filesystem such as {!section-cgi}. *)

(** {1 Net} *)

include Mehari_mirage.S with type addr = Ipaddr.t
(** @closed *)

(** @closed *)
include
  Mehari.UNIX
    with module IO := IO
     and type addr := addr
     and type dir_path := string

(** {1 Mime} *)

val from_filename :
  ?lookup:[ `Ext | `Content | `Both ] ->
  ?charset:string ->
  string ->
  Mehari.mime option Lwt.t
(** [from_filename ?lookup_into ?charset ?lang fname] tries to create a
    {!type:Mehari.mime} by performing a mime lookup depending of the value of
    [lookup]:
    - [`Ext]: guesses on the file extension of [fname];
    - [`Content]: guesses on content of [fname];
    - [`Both]: performs successivly a lookup on content and file extension.

    Returns [Mehari.make_mime ?charset "text/gemini"] if one of the previous
    lookup fails.

    @raise Unix.Unix_error if a lookup based on content is performed and
      reading of [fname] fails *)

(** {1:cgi CGI} *)

(** Mehari supports CGI scripting as described in RFC 3875

    The CGI script must write the gemini response to the stdout stream. Status
    code and meta string on the first line, and the optional response body on
    subsequent lines. The bytes generated by the CGI script will be forwarded
    verbatim to the Gemini client, without any additional modification by the
    server.

    {2 Environment Variables}

    Some variables are empty for compatibility with other CGI script.

    Let's say that the url requested is [gemini://localhost/cgi/foo.cgi?input]:

      - [AUTH_TYPE]: [CERTIFICATE] if a client certificate is provided, empty
          otherwise.
      - [CONTENT_LENGTH]: Empty.
      - [CONTENT_TYPE]: Empty.
      - [GATEWAY_INTERFACE]: [CGI/1.1].
      - [PATH_INFO]: Example value: [/cgi/foo.cgi].
      - [PATH_TRANSLATED]: Example value: [/cgi/foo.cgi].
      - [QUERY_STRING]: Example value: [input].
      - [REMOTE_ADDR]: Example value: [127.0.0.1].
      - [REMOTE_HOST]: Same as [REMOTE_ADDR].
      - [REMOTE_IDENT]: Empty.
      - [REMOTE_METHOD]: Empty.
      - [REMOTE_USER]: Client certificate common if it is provided, empty
          otherwise.
      - [SCRIPT_NAME]: Example value: [/var/cgi/foo.cgi].
      - [SERVER_NAME]: Example value: [/var/cgi/foo.cgi].
      - [SERVER_PORT]: Example value: [1965].
      - [SERVER_PROTOCOL]: [GEMINI].
      - [SERVER_SOFTWARE]: Example value: [Mehari/1.0].

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

    - [timeout] defaults to [5.0].
    - [nph] decides if NPH (Non-Parsed Header) is enable. Defaults to
      [false]. *)

(** {1 Entry point} *)

val run_lwt :
  ?port:int ->
  ?timeout:float ->
  ?certchains:(string * string) list ->
  ?v4:string ->
  ?v6:string ->
  handler ->
  unit Lwt.t
(** See {!val:Mehari_mirage.S.run}.
    - [v4] must be written as an IPv4 CIDR.
    - [v6] must be written as an IPv6 CIDR. *)

val run :
  ?port:int ->
  ?timeout:float ->
  ?certchains:(string * string) list ->
  ?v4:string ->
  ?v6:string ->
  handler ->
  unit
(** Like {!val:run_lwt} but calls [Lwt_main.run] internally. *)
