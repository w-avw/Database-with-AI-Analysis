--
-- PostgreSQL database dump
--

-- Dumped from database version 16.9 (Debian 16.9-1.pgdg120+1)
-- Dumped by pg_dump version 16.9 (Debian 16.9-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: calls; Type: TABLE; Schema: public; Owner: myuser
--

CREATE TABLE public.calls (
    db_id integer NOT NULL,
    source_id bigint,
    date_time timestamp without time zone,
    source_type text,
    source text,
    source_fleet text,
    destination_type text,
    destination text,
    destination_fleet text,
    service_type text,
    service_type_info text,
    ai_security text,
    e2ee_security text,
    disconnection_cause text,
    duration_secs integer,
    time_in_queue_secs integer,
    priority integer,
    source_location text,
    cell_reselection text,
    status text,
    voice_recording text,
    call_forwarding text,
    source_nms text,
    network_controller text,
    utc_offset_minutes integer
);


ALTER TABLE public.calls OWNER TO myuser;

--
-- Name: calls_db_id_seq; Type: SEQUENCE; Schema: public; Owner: myuser
--

CREATE SEQUENCE public.calls_db_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.calls_db_id_seq OWNER TO myuser;

--
-- Name: calls_db_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: myuser
--

ALTER SEQUENCE public.calls_db_id_seq OWNED BY public.calls.db_id;


--
-- Name: calls_staging; Type: TABLE; Schema: public; Owner: myuser
--

CREATE TABLE public.calls_staging (
    db_id integer DEFAULT nextval('public.calls_db_id_seq'::regclass) NOT NULL,
    source_id bigint,
    date_time timestamp without time zone,
    source_type text,
    source text,
    source_fleet text,
    destination_type text,
    destination text,
    destination_fleet text,
    service_type text,
    service_type_info text,
    ai_security text,
    e2ee_security text,
    disconnection_cause text,
    duration_secs integer,
    time_in_queue_secs integer,
    priority integer,
    source_location text,
    cell_reselection text,
    status text,
    voice_recording text,
    call_forwarding text,
    source_nms text,
    network_controller text,
    utc_offset_minutes integer
);


ALTER TABLE public.calls_staging OWNER TO myuser;

--
-- Name: suggestions; Type: TABLE; Schema: public; Owner: myuser
--

CREATE TABLE public.suggestions (
    id integer NOT NULL,
    call_id integer,
    suggestion text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.suggestions OWNER TO myuser;

--
-- Name: suggestions_id_seq; Type: SEQUENCE; Schema: public; Owner: myuser
--

CREATE SEQUENCE public.suggestions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suggestions_id_seq OWNER TO myuser;

--
-- Name: suggestions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: myuser
--

ALTER SEQUENCE public.suggestions_id_seq OWNED BY public.suggestions.id;


--
-- Name: calls db_id; Type: DEFAULT; Schema: public; Owner: myuser
--

ALTER TABLE ONLY public.calls ALTER COLUMN db_id SET DEFAULT nextval('public.calls_db_id_seq'::regclass);


--
-- Name: suggestions id; Type: DEFAULT; Schema: public; Owner: myuser
--

ALTER TABLE ONLY public.suggestions ALTER COLUMN id SET DEFAULT nextval('public.suggestions_id_seq'::regclass);


--
-- Data for Name: calls; Type: TABLE DATA; Schema: public; Owner: myuser
--

COPY public.calls (db_id, source_id, date_time, source_type, source, source_fleet, destination_type, destination, destination_fleet, service_type, service_type_info, ai_security, e2ee_security, disconnection_cause, duration_secs, time_in_queue_secs, priority, source_location, cell_reselection, status, voice_recording, call_forwarding, source_nms, network_controller, utc_offset_minutes) FROM stdin;
\.


--
-- Data for Name: calls_staging; Type: TABLE DATA; Schema: public; Owner: myuser
--

COPY public.calls_staging (db_id, source_id, date_time, source_type, source, source_fleet, destination_type, destination, destination_fleet, service_type, service_type_info, ai_security, e2ee_security, disconnection_cause, duration_secs, time_in_queue_secs, priority, source_location, cell_reselection, status, voice_recording, call_forwarding, source_nms, network_controller, utc_offset_minutes) FROM stdin;
\.


--
-- Data for Name: suggestions; Type: TABLE DATA; Schema: public; Owner: myuser
--

COPY public.suggestions (id, call_id, suggestion, created_at) FROM stdin;
\.


--
-- Name: calls_db_id_seq; Type: SEQUENCE SET; Schema: public; Owner: myuser
--

SELECT pg_catalog.setval('public.calls_db_id_seq', 1, false);


--
-- Name: suggestions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: myuser
--

SELECT pg_catalog.setval('public.suggestions_id_seq', 1, false);


--
-- Name: calls calls_pkey; Type: CONSTRAINT; Schema: public; Owner: myuser
--

ALTER TABLE ONLY public.calls
    ADD CONSTRAINT calls_pkey PRIMARY KEY (db_id);


--
-- Name: suggestions suggestions_pkey; Type: CONSTRAINT; Schema: public; Owner: myuser
--

ALTER TABLE ONLY public.suggestions
    ADD CONSTRAINT suggestions_pkey PRIMARY KEY (id);


--
-- Name: suggestions suggestions_call_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: myuser
--

ALTER TABLE ONLY public.suggestions
    ADD CONSTRAINT suggestions_call_id_fkey FOREIGN KEY (call_id) REFERENCES public.calls(db_id);


--
-- PostgreSQL database dump complete
--

