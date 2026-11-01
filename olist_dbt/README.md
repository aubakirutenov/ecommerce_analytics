# olist_dbt

The dbt Core project behind the [E-commerce Analytics](../README.md) portfolio project. It rebuilds the Olist star schema in PostgreSQL from the raw tables, in two layers:

- `models/staging/`: one view per raw table (7), with renamed columns and fixed types.
- `models/marts/`: the star schema as tables: `dim_customer`, `dim_seller`, `dim_product`, `dim_date`, `fact_orders`, `fact_order_items`.

45 tests check keys, relationships between facts and dimensions, and accepted values. The marts match the original SQL build to the cent; see the [dbt pipeline](../README.md#dbt-pipeline) section of the main README.

## Run

Requires dbt Core with the Postgres adapter and a profile named `olist_dbt` in `~/.dbt/profiles.yml` that points to the database with the `olist` schema.

```bash
dbt build          # build all models and run all tests
dbt docs generate  # documentation and lineage graph
dbt docs serve
```
