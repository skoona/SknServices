--
-- PostgreSQL database dump
--

-- Dumped from database version 10.3
-- Dumped by pg_dump version 10.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: content_profile_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_profile_entries (
    id integer NOT NULL,
    topic_value character varying,
    topic_type character varying(255),
    topic_type_description character varying(255),
    content_value character varying,
    content_type character varying(255),
    content_type_description character varying(255),
    description character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: content_profile_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_profile_entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_profile_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_profile_entries_id_seq OWNED BY public.content_profile_entries.id;


--
-- Name: content_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_profiles (
    id integer NOT NULL,
    person_authentication_key character varying(255),
    profile_type_id integer,
    authentication_provider character varying(255),
    username character varying(255),
    display_name character varying(255),
    email character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: content_profiles_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_profiles_entries (
    id integer NOT NULL,
    content_profile_id integer,
    content_profile_entry_id integer
);


--
-- Name: content_profiles_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_profiles_entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_profiles_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_profiles_entries_id_seq OWNED BY public.content_profiles_entries.id;


--
-- Name: content_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_profiles_id_seq OWNED BY public.content_profiles.id;


--
-- Name: content_type_opts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_type_opts (
    id integer NOT NULL,
    value character varying(255),
    description character varying(255),
    type_name character varying(255),
    content_type_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: content_type_opts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_type_opts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_type_opts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_type_opts_id_seq OWNED BY public.content_type_opts.id;


--
-- Name: content_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_types (
    id integer NOT NULL,
    name character varying(255),
    description character varying(255),
    value_data_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: content_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_types_id_seq OWNED BY public.content_types.id;


--
-- Name: profile_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profile_types (
    id integer NOT NULL,
    name character varying(255),
    description character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: profile_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.profile_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profile_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.profile_types_id_seq OWNED BY public.profile_types.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: topic_type_opts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.topic_type_opts (
    id integer NOT NULL,
    value character varying(255),
    description character varying(255),
    type_name character varying(255),
    topic_type_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: topic_type_opts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.topic_type_opts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: topic_type_opts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.topic_type_opts_id_seq OWNED BY public.topic_type_opts.id;


--
-- Name: topic_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.topic_types (
    id integer NOT NULL,
    name character varying(255),
    description character varying(255),
    value_based_y_n character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: topic_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.topic_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: topic_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.topic_types_id_seq OWNED BY public.topic_types.id;


--
-- Name: user_group_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_group_roles (
    id integer NOT NULL,
    name character varying(255),
    description character varying(255),
    group_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_group_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_group_roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_group_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_group_roles_id_seq OWNED BY public.user_group_roles.id;


--
-- Name: user_group_roles_user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_group_roles_user_roles (
    id integer NOT NULL,
    user_group_role_id integer,
    user_role_id integer
);


--
-- Name: user_group_roles_user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_group_roles_user_roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_group_roles_user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_group_roles_user_roles_id_seq OWNED BY public.user_group_roles_user_roles.id;


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_roles (
    id integer NOT NULL,
    name character varying(255),
    description character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_roles_id_seq OWNED BY public.user_roles.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(255),
    name character varying(255),
    email character varying(255),
    password_digest character varying(255),
    remember_token character varying(255),
    password_reset_token character varying(255),
    password_reset_date timestamp without time zone,
    assigned_groups character varying(4096),
    roles character varying(4096),
    active boolean DEFAULT true,
    file_access_token character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    person_authentication_key character varying(255),
    assigned_roles character varying(4096),
    remember_token_digest character varying(255),
    user_options character varying(4096)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: content_profile_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_profile_entries ALTER COLUMN id SET DEFAULT nextval('public.content_profile_entries_id_seq'::regclass);


--
-- Name: content_profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_profiles ALTER COLUMN id SET DEFAULT nextval('public.content_profiles_id_seq'::regclass);


--
-- Name: content_profiles_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_profiles_entries ALTER COLUMN id SET DEFAULT nextval('public.content_profiles_entries_id_seq'::regclass);


--
-- Name: content_type_opts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_type_opts ALTER COLUMN id SET DEFAULT nextval('public.content_type_opts_id_seq'::regclass);


--
-- Name: content_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_types ALTER COLUMN id SET DEFAULT nextval('public.content_types_id_seq'::regclass);


--
-- Name: profile_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_types ALTER COLUMN id SET DEFAULT nextval('public.profile_types_id_seq'::regclass);


--
-- Name: topic_type_opts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topic_type_opts ALTER COLUMN id SET DEFAULT nextval('public.topic_type_opts_id_seq'::regclass);


--
-- Name: topic_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topic_types ALTER COLUMN id SET DEFAULT nextval('public.topic_types_id_seq'::regclass);


--
-- Name: user_group_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_group_roles ALTER COLUMN id SET DEFAULT nextval('public.user_group_roles_id_seq'::regclass);


--
-- Name: user_group_roles_user_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_group_roles_user_roles ALTER COLUMN id SET DEFAULT nextval('public.user_group_roles_user_roles_id_seq'::regclass);


--
-- Name: user_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles ALTER COLUMN id SET DEFAULT nextval('public.user_roles_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: content_profile_entries content_profile_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_profile_entries
    ADD CONSTRAINT content_profile_entries_pkey PRIMARY KEY (id);


--
-- Name: content_profiles_entries content_profiles_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_profiles_entries
    ADD CONSTRAINT content_profiles_entries_pkey PRIMARY KEY (id);


--
-- Name: content_profiles content_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_profiles
    ADD CONSTRAINT content_profiles_pkey PRIMARY KEY (id);


--
-- Name: content_type_opts content_type_opts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_type_opts
    ADD CONSTRAINT content_type_opts_pkey PRIMARY KEY (id);


--
-- Name: content_types content_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_types
    ADD CONSTRAINT content_types_pkey PRIMARY KEY (id);


--
-- Name: profile_types profile_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_types
    ADD CONSTRAINT profile_types_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: topic_type_opts topic_type_opts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topic_type_opts
    ADD CONSTRAINT topic_type_opts_pkey PRIMARY KEY (id);


--
-- Name: topic_types topic_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topic_types
    ADD CONSTRAINT topic_types_pkey PRIMARY KEY (id);


--
-- Name: user_group_roles user_group_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_group_roles
    ADD CONSTRAINT user_group_roles_pkey PRIMARY KEY (id);


--
-- Name: user_group_roles_user_roles user_group_roles_user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_group_roles_user_roles
    ADD CONSTRAINT user_group_roles_user_roles_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_content_profiles_entries_on_content_profile_entry_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_profiles_entries_on_content_profile_entry_id ON public.content_profiles_entries USING btree (content_profile_entry_id);


--
-- Name: index_content_profiles_entries_on_content_profile_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_profiles_entries_on_content_profile_id ON public.content_profiles_entries USING btree (content_profile_id);


--
-- Name: index_content_profiles_on_person_authentication_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_content_profiles_on_person_authentication_key ON public.content_profiles USING btree (person_authentication_key);


--
-- Name: index_content_profiles_on_profile_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_profiles_on_profile_type_id ON public.content_profiles USING btree (profile_type_id);


--
-- Name: index_content_types_on_content_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_content_types_on_content_type_id ON public.content_type_opts USING btree (content_type_id);


--
-- Name: index_topic_types_on_topic_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_topic_types_on_topic_type_id ON public.topic_type_opts USING btree (topic_type_id);


--
-- Name: index_user_group_roles_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_group_roles_on_name ON public.user_group_roles USING btree (name);


--
-- Name: index_user_group_roles_user_roles_on_user_group_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_group_roles_user_roles_on_user_group_role_id ON public.user_group_roles_user_roles USING btree (user_group_role_id);


--
-- Name: index_user_group_roles_user_roles_on_user_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_group_roles_user_roles_on_user_role_id ON public.user_group_roles_user_roles USING btree (user_role_id);


--
-- Name: index_user_roles_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_roles_on_name ON public.user_roles USING btree (name);


--
-- Name: index_users_on_person_authentication_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_person_authentication_key ON public.users USING btree (person_authentication_key);


--
-- Name: index_users_on_remember_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_remember_token ON public.users USING btree (remember_token);


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_username ON public.users USING btree (username);


--
-- Name: user_group_roles_user_roles fk_rails_2e964899e5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_group_roles_user_roles
    ADD CONSTRAINT fk_rails_2e964899e5 FOREIGN KEY (user_role_id) REFERENCES public.user_roles(id);


--
-- Name: content_profiles fk_rails_5ddd6208a6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_profiles
    ADD CONSTRAINT fk_rails_5ddd6208a6 FOREIGN KEY (profile_type_id) REFERENCES public.profile_types(id);


--
-- Name: content_profiles_entries fk_rails_609cf11d23; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_profiles_entries
    ADD CONSTRAINT fk_rails_609cf11d23 FOREIGN KEY (content_profile_id) REFERENCES public.content_profiles(id);


--
-- Name: content_type_opts fk_rails_7414f04fa1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_type_opts
    ADD CONSTRAINT fk_rails_7414f04fa1 FOREIGN KEY (content_type_id) REFERENCES public.content_types(id);


--
-- Name: content_profiles_entries fk_rails_8246790765; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_profiles_entries
    ADD CONSTRAINT fk_rails_8246790765 FOREIGN KEY (content_profile_entry_id) REFERENCES public.content_profile_entries(id);


--
-- Name: user_group_roles_user_roles fk_rails_846806fa23; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_group_roles_user_roles
    ADD CONSTRAINT fk_rails_846806fa23 FOREIGN KEY (user_group_role_id) REFERENCES public.user_group_roles(id);


--
-- Name: topic_type_opts fk_rails_b4cea7337a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topic_type_opts
    ADD CONSTRAINT fk_rails_b4cea7337a FOREIGN KEY (topic_type_id) REFERENCES public.topic_types(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20160113200706');


