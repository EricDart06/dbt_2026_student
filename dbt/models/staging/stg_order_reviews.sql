{#
  SESSION 3 - EXAMPLE (I do): the instructor walks through this one.

  THE DEDUP LESSON.

  You'd expect one row per review_id. The raw data disagrees twice over:
    - 789 review_ids are attached to more than one order (one survey that covered
      several orders from the same customer), and
    - 547 orders have more than one review.

  Only (review_id, order_id) is unique. But the question the business asks is
  "how did the customer rate THIS ORDER?", so we choose the grain: one row per
  order, keeping the most recently answered review. Choosing the grain is a
  decision, not something the data hands you.
#}

with source as (

    select * from {{ source('olist', 'order_reviews') }}

),

renamed as (

    select
        cast(review_id    as varchar) as review_id,
        cast(order_id     as varchar) as order_id,
        cast(review_score as integer) as review_score,

        -- CLEAN: blank or whitespace-only comments become null, so "has a comment"
        -- means there is actually something to read.
        nullif(trim(review_comment_title),   '') as comment_title,
        nullif(trim(review_comment_message), '') as comment_message,

        cast(review_creation_date    as timestamp) as survey_sent_at,
        cast(review_answer_timestamp as timestamp) as answered_at

    from source

),

deduplicated as (

    select * from renamed
    qualify row_number() over (
        partition by order_id
        order by answered_at desc, review_id   -- latest answer wins; review_id breaks ties
    ) = 1

),

derived as (

    select
        *,
        comment_message is not null as has_comment,
        review_score <= 2           as is_negative

    from deduplicated

)

select * from derived
