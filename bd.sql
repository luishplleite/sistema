-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.activity_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  restaurant_id uuid,
  user_id uuid,
  user_name character varying,
  action character varying NOT NULL,
  entity_type character varying NOT NULL,
  entity_id uuid,
  description text,
  ip_address inet,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT activity_logs_pkey PRIMARY KEY (id),
  CONSTRAINT activity_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.add_on_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  restaurant_id uuid NOT NULL,
  name character varying NOT NULL,
  description text,
  selection_type character varying NOT NULL CHECK (selection_type::text = ANY (ARRAY['single'::character varying, 'multiple'::character varying]::text[])),
  min_selection integer DEFAULT 0,
  max_selection integer,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT add_on_categories_pkey PRIMARY KEY (id),
  CONSTRAINT add_on_categories_restaurant_id_fkey FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id)
);
CREATE TABLE public.buffer_mensagem (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  cell text,
  message text,
  idMessage text,
  timestamp text,
  CONSTRAINT buffer_mensagem_pkey PRIMARY KEY (id)
);
CREATE TABLE public.business_types (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL UNIQUE,
  description text,
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT business_types_pkey PRIMARY KEY (id)
);
CREATE TABLE public.chat_histories (
  id integer NOT NULL DEFAULT nextval('chat_histories_id_seq'::regclass),
  session_id character varying NOT NULL,
  message jsonb NOT NULL,
  CONSTRAINT chat_histories_pkey PRIMARY KEY (id)
);
CREATE TABLE public.coupon_usage (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  coupon_id uuid NOT NULL,
  order_id uuid NOT NULL,
  customer_id uuid,
  discount_applied numeric NOT NULL,
  used_at timestamp with time zone DEFAULT now(),
  CONSTRAINT coupon_usage_pkey PRIMARY KEY (id),
  CONSTRAINT coupon_usage_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id),
  CONSTRAINT coupon_usage_coupon_id_fkey FOREIGN KEY (coupon_id) REFERENCES public.coupons(id)
);
CREATE TABLE public.coupons (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  restaurant_id uuid NOT NULL,
  code character varying NOT NULL,
  name character varying NOT NULL,
  description text,
  discount_type character varying NOT NULL CHECK (discount_type::text = ANY (ARRAY['percentage'::character varying::text, 'fixed'::character varying::text, 'free_delivery'::character varying::text])),
  discount_value numeric NOT NULL CHECK (discount_value >= 0::numeric),
  minimum_order_value numeric DEFAULT 0.00,
  maximum_discount numeric,
  usage_limit integer,
  usage_count integer DEFAULT 0,
  valid_from timestamp with time zone DEFAULT now(),
  valid_until timestamp with time zone,
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT coupons_pkey PRIMARY KEY (id)
);
CREATE TABLE public.customers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  restaurant_id uuid NOT NULL,
  name character varying NOT NULL,
  phone character varying,
  email character varying,
  address text,
  city character varying,
  zip_code character varying,
  birth_date date,
  preferences jsonb DEFAULT '{}'::jsonb,
  total_orders integer DEFAULT 0,
  total_spent numeric DEFAULT 0.00,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  cpf numeric,
  CONSTRAINT customers_pkey PRIMARY KEY (id)
);
CREATE TABLE public.deliverers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  restaurant_id uuid NOT NULL,
  name character varying NOT NULL,
  cpf character varying,
  phone character varying NOT NULL,
  email character varying,
  motorcycle_plate character varying,
  motorcycle_model character varying,
  motorcycle_year integer,
  type character varying NOT NULL CHECK (type::text = ANY (ARRAY['own'::character varying::text, 'third-party'::character varying::text])),
  salary numeric,
  commission numeric CHECK (commission >= 0::numeric AND commission <= 100::numeric),
  balance numeric DEFAULT 0.00,
  status character varying DEFAULT 'active'::character varying CHECK (status::text = ANY (ARRAY['active'::character varying::text, 'inactive'::character varying::text, 'busy'::character varying::text, 'unavailable'::character varying::text])),
  last_location point,
  last_seen timestamp with time zone DEFAULT now(),
  total_deliveries integer DEFAULT 0,
  rating numeric DEFAULT 5.00 CHECK (rating >= 0::numeric AND rating <= 5::numeric),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  id_pedido text,
  CONSTRAINT deliverers_pkey PRIMARY KEY (id)
);
CREATE TABLE public.notifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  restaurant_id uuid NOT NULL,
  user_id uuid,
  title character varying NOT NULL,
  message text NOT NULL,
  type character varying DEFAULT 'info'::character varying CHECK (type::text = ANY (ARRAY['info'::character varying::text, 'success'::character varying::text, 'warning'::character varying::text, 'error'::character varying::text])),
  read_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT notifications_pkey PRIMARY KEY (id),
  CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.order_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL,
  product_id uuid,
  product_name character varying NOT NULL,
  quantity integer NOT NULL DEFAULT 1 CHECK (quantity > 0),
  price numeric NOT NULL CHECK (price >= 0::numeric),
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  status text,
  selected_add_ons jsonb,
  CONSTRAINT order_items_pkey PRIMARY KEY (id),
  CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.orders (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  restaurant_id uuid NOT NULL,
  customer_id uuid,
  deliverer_id uuid,
  status character varying DEFAULT 'novo'::character varying CHECK (status::text = ANY (ARRAY['novo'::character varying::text, 'aceito'::character varying::text, 'preparo'::character varying::text, 'pronto'::character varying::text, 'saiu_entrega'::character varying::text, 'entregue'::character varying::text, 'rejeitado'::character varying::text, 'cancelado'::character varying::text, 'Aberta'::character varying::text, 'encerrado'::character varying::text, 'aguardando'::character varying::text])),
  delivery_address text NOT NULL,
  delivery_coordinates point,
  delivery_fee numeric DEFAULT 0.00 CHECK (delivery_fee >= 0::numeric),
  subtotal numeric DEFAULT 0.00 CHECK (subtotal >= 0::numeric),
  total numeric DEFAULT 0.00 CHECK (total >= 0::numeric),
  notes text,
  customer_name character varying NOT NULL,
  customer_phone character varying NOT NULL,
  payment_method text CHECK (payment_method = ANY (ARRAY['money'::character varying::text, 'card'::character varying::text, 'pix'::character varying::text, 'voucher'::character varying::text, 'Cartão de Crédito/Débito'::character varying::text])),
  payment_status character varying DEFAULT 'pending'::character varying CHECK (payment_status::text = ANY (ARRAY['pending'::character varying::text, 'paid'::character varying::text, 'cancelled'::character varying::text, 'pago'::character varying::text])),
  change_for_amount numeric CHECK (change_for_amount IS NULL OR change_for_amount >= 0::numeric),
  change_amount numeric CHECK (change_amount IS NULL OR change_amount >= 0::numeric),
  estimated_delivery_time timestamp with time zone,
  accepted_at timestamp with time zone,
  prepared_at timestamp with time zone,
  delivered_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  delivery_distance numeric,
  delivery_duration numeric,
  order type text,
  return order boolean,
  order_items text,
  order_balcao text,
  order_mesa text,
  status_env_aceito boolean,
  idpix text,
  CONSTRAINT orders_pkey PRIMARY KEY (id)
);
CREATE TABLE public.product_add_on_categories_link (
  product_id uuid NOT NULL,
  add_on_category_id uuid NOT NULL,
  CONSTRAINT product_add_on_categories_link_pkey PRIMARY KEY (product_id, add_on_category_id),
  CONSTRAINT product_add_on_categories_link_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id),
  CONSTRAINT product_add_on_categories_link_add_on_category_id_fkey FOREIGN KEY (add_on_category_id) REFERENCES public.add_on_categories(id)
);
CREATE TABLE public.product_add_ons (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  add_on_category_id uuid NOT NULL,
  restaurant_id uuid NOT NULL,
  name character varying NOT NULL,
  price numeric NOT NULL DEFAULT 0.00 CHECK (price >= 0::numeric),
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT product_add_ons_pkey PRIMARY KEY (id),
  CONSTRAINT product_add_ons_add_on_category_id_fkey FOREIGN KEY (add_on_category_id) REFERENCES public.add_on_categories(id),
  CONSTRAINT product_add_ons_restaurant_id_fkey FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id)
);
CREATE TABLE public.product_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  restaurant_id uuid NOT NULL,
  name character varying NOT NULL,
  description text,
  display_order integer DEFAULT 0,
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT product_categories_pkey PRIMARY KEY (id)
);
CREATE TABLE public.product_to_product_add_ons_link (
  product_id uuid NOT NULL,
  add_on_id uuid NOT NULL,
  CONSTRAINT product_to_product_add_ons_link_pkey PRIMARY KEY (product_id, add_on_id),
  CONSTRAINT product_to_product_add_ons_link_add_on_id_fkey FOREIGN KEY (add_on_id) REFERENCES public.product_add_ons(id),
  CONSTRAINT product_to_product_add_ons_link_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.products (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  restaurant_id uuid NOT NULL,
  category_id uuid,
  name character varying NOT NULL,
  description text,
  price numeric NOT NULL CHECK (price >= 0::numeric),
  image_url text,
  active boolean DEFAULT true,
  display_order integer DEFAULT 0,
  preparation_time integer DEFAULT 0,
  calories integer,
  ingredients ARRAY,
  allergens ARRAY,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  impressao text,
  adicional_produtos uuid,
  CONSTRAINT products_pkey PRIMARY KEY (id),
  CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.product_categories(id),
  CONSTRAINT products_adicional_produtos_fkey FOREIGN KEY (adicional_produtos) REFERENCES public.add_on_categories(id)
);
CREATE TABLE public.provisional_order_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  session_key text NOT NULL,
  restaurant_id uuid NOT NULL,
  product_id uuid,
  product_name text NOT NULL,
  base_price numeric NOT NULL,
  final_price numeric NOT NULL,
  quantity integer NOT NULL DEFAULT 1,
  selected_add_ons jsonb,
  add_ons_total numeric,
  add_ons_description text,
  notes text,
  item_total numeric NOT NULL,
  item_sequence text,
  sequence_id text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT provisional_order_items_pkey PRIMARY KEY (id),
  CONSTRAINT provisional_order_items_restaurant_id_fkey FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id)
);
CREATE TABLE public.restaurants (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL,
  owner_id uuid,
  owner_name character varying NOT NULL,
  owner_cpf character varying,
  owner_phone character varying NOT NULL,
  cnpj character varying,
  business_type character varying,
  address text NOT NULL,
  city character varying NOT NULL,
  state character varying NOT NULL,
  zip_code character varying NOT NULL,
  primary_color character varying DEFAULT '#28a745'::character varying,
  logo_url text,
  delivery_retun numeric DEFAULT 5.00 CHECK (delivery_retun >= 0::numeric),
  minimum_delivery_fee numeric DEFAULT 8.00 CHECK (minimum_delivery_fee >= 0::numeric),
  delivery_fee_per_km numeric DEFAULT 2.50 CHECK (delivery_fee_per_km >= 0::numeric),
  minimum_distance_km numeric DEFAULT 3.0 CHECK (minimum_distance_km > 0::numeric),
  preparation_time integer DEFAULT 30 CHECK (preparation_time > 0),
  delivery_radius numeric DEFAULT 10.0 CHECK (delivery_radius > 0::numeric),
  minimum_order numeric DEFAULT 0.00 CHECK (minimum_order >= 0::numeric),
  business_hours jsonb DEFAULT '{"friday": {"open": "08:00", "close": "18:00", "closed": false}, "monday": {"open": "08:00", "close": "18:00", "closed": false}, "sunday": {"open": "08:00", "close": "18:00", "closed": true}, "tuesday": {"open": "08:00", "close": "18:00", "closed": false}, "saturday": {"open": "08:00", "close": "18:00", "closed": false}, "thursday": {"open": "08:00", "close": "18:00", "closed": false}, "wednesday": {"open": "08:00", "close": "18:00", "closed": false}}'::jsonb,
  notification_settings jsonb DEFAULT '{"email": true, "sound": true, "whatsapp": true}'::jsonb,
  asaas_config jsonb DEFAULT '{}'::jsonb,
  status character varying DEFAULT 'active'::character varying CHECK (status::text = ANY (ARRAY['active'::character varying::text, 'inactive'::character varying::text, 'suspended'::character varying::text])),
  plan character varying DEFAULT 'basic'::character varying CHECK (plan::text = ANY (ARRAY['basic'::character varying::text, 'premium'::character varying::text, 'enterprise'::character varying::text])),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  latitude numeric,
  longitude numeric,
  pedidos_online boolean,
  link_cardapio text,
  api_assas text,
  CONSTRAINT restaurants_pkey PRIMARY KEY (id)
);
CREATE TABLE public.system_settings (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  restaurant_id uuid NOT NULL,
  setting_key character varying NOT NULL,
  setting_value jsonb NOT NULL,
  description text,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT system_settings_pkey PRIMARY KEY (id)
);
CREATE TABLE public.withdrawal_requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  restaurant_id uuid NOT NULL,
  deliverer_id uuid NOT NULL,
  amount numeric NOT NULL CHECK (amount > 0::numeric),
  status character varying DEFAULT 'pending'::character varying CHECK (status::text = ANY (ARRAY['pending'::character varying::text, 'approved'::character varying::text, 'rejected'::character varying::text, 'paid'::character varying::text])),
  rejection_reason text,
  bank_name character varying,
  account_number character varying,
  account_holder character varying,
  approved_at timestamp with time zone,
  rejected_at timestamp with time zone,
  paid_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT withdrawal_requests_pkey PRIMARY KEY (id),
  CONSTRAINT withdrawal_requests_deliverer_id_fkey FOREIGN KEY (deliverer_id) REFERENCES public.deliverers(id)
);
