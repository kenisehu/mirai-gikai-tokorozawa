-- Source checked 2026-09-09 against the official bill PDF.
-- This is a multi-year continuing expenditure change, not a ¥2.3bn FY2026 add-on.
do $$
declare
  affected_rows integer;
begin
  update public.bill_contents
  set content = replace(
    replace(
      content,
      '年度途中の事情変化に対応する追加予算です。事業の必要性、財源、翌年度以降の負担が市民生活に関係します。',
      '令和8年度の支出額2億7,500万円は変更せず、事業期間を令和15年度まで5年延長し、複数年度の事業総額を22億8,657万4千円増やす計画です。年度ごとの負担と、区画整理の完了時期が市民生活に関係します。'
    ),
    '追加額の根拠、国・県支出金や基金などの財源、事業の実施時期、成果を測る方法を確認する必要があります。',
    '事業総額が153億1,367万5千円から176億24万9千円へ増える根拠、令和11年度以降に追加される年度別の支出予定、5年延長後の完了見通しを確認する必要があります。'
  )
  where bill_id = '91f6e748-79c7-4f8a-a27a-18a124767a0e'
    and difficulty_level in ('normal', 'hard')
    and content like '%年度途中の事情変化に対応する追加予算です。%'
    and content like '%追加額の根拠、国・県支出金や基金などの財源%';

  get diagnostics affected_rows = row_count;
  if affected_rows <> 2 then
    raise exception 'Expected to correct 2 bill content rows, corrected %', affected_rows;
  end if;
end
$$;
