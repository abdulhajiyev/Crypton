create extension if not exists "pg_cron" with schema "public" version '1.4-1';

create type "public"."user_settings_type" as enum ('timezone');

create table "public"."configs" (
    "id" integer not null,
    "bot_id" text not null,
    "bot_guild_id" text,
    "activity_name" text,
    "activity_type" integer,
    "bot_dev_folder" text,
    "created_at" text,
    "discord_client_id" text,
    "name" text,
    "notify_channel_id" text,
    "perma_invite" text,
    "website" text,
    "monitoring_channel_id" text
);


alter table "public"."configs" enable row level security;

create table "public"."guilds" (
    "id" integer generated by default as identity not null,
    "guild_id" text not null,
    "avatar" text,
    "name" text,
    "premium" boolean default false,
    "created_at" text
);


alter table "public"."guilds" enable row level security;

create table "public"."guilds_plugins" (
    "id" integer generated by default as identity not null,
    "name" text,
    "owner" text,
    "enabled" boolean,
    "metadata" jsonb,
    "created_at" text
);


alter table "public"."guilds_plugins" enable row level security;

create table "public"."plugins" (
    "id" integer generated by default as identity not null,
    "name" text,
    "description" text,
    "enabled" boolean,
    "premium" boolean,
    "category" text default 'miscellaneous'::text,
    "created_at" text
);


alter table "public"."plugins" enable row level security;

create table "public"."users_settings" (
    "id" bigint generated by default as identity not null,
    "created_at" timestamp with time zone default now(),
    "user_id" text not null,
    "metadata" jsonb,
    "type" user_settings_type
);


alter table "public"."users_settings" enable row level security;

CREATE UNIQUE INDEX configs_pkey ON public.configs USING btree (id);

CREATE UNIQUE INDEX guilds_guild_id_key ON public.guilds USING btree (guild_id);

CREATE UNIQUE INDEX guilds_pkey ON public.guilds USING btree (id);

CREATE UNIQUE INDEX guilds_plugins_pkey ON public.guilds_plugins USING btree (id);

CREATE UNIQUE INDEX plugins_name_key ON public.plugins USING btree (name);

CREATE UNIQUE INDEX plugins_pkey ON public.plugins USING btree (id);

CREATE UNIQUE INDEX users_settings_pkey ON public.users_settings USING btree (id, user_id);

alter table "public"."configs" add constraint "configs_pkey" PRIMARY KEY using index "configs_pkey";

alter table "public"."guilds" add constraint "guilds_pkey" PRIMARY KEY using index "guilds_pkey";

alter table "public"."guilds_plugins" add constraint "guilds_plugins_pkey" PRIMARY KEY using index "guilds_plugins_pkey";

alter table "public"."plugins" add constraint "plugins_pkey" PRIMARY KEY using index "plugins_pkey";

alter table "public"."users_settings" add constraint "users_settings_pkey" PRIMARY KEY using index "users_settings_pkey";

alter table "public"."guilds" add constraint "guilds_guild_id_key" UNIQUE using index "guilds_guild_id_key";

alter table "public"."guilds_plugins" add constraint "guilds_plugins_name_fkey" FOREIGN KEY (name) REFERENCES plugins(name) not valid;

alter table "public"."guilds_plugins" validate constraint "guilds_plugins_name_fkey";

alter table "public"."guilds_plugins" add constraint "guilds_plugins_owner_fkey" FOREIGN KEY (owner) REFERENCES guilds(guild_id) ON DELETE CASCADE not valid;

alter table "public"."guilds_plugins" validate constraint "guilds_plugins_owner_fkey";

alter table "public"."plugins" add constraint "plugins_name_key" UNIQUE using index "plugins_name_key";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.reset_chat_gpt_plugin()
 RETURNS void
 LANGUAGE plpgsql
AS $function$ BEGIN
    UPDATE
        guilds_plugins
    SET
        metadata = jsonb_set(metadata, '{usage}', '100' :: jsonb)
    WHERE
        name = 'chatGtp';

END;

$function$
;

