"use client";

import { CheckCircle2 } from "lucide-react";
import { useActionState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { submitCorrectionReport } from "../../server/actions/submit-correction-report";

export function CorrectionReportForm({
  billId = "",
  billName = "",
}: {
  billId?: string;
  billName?: string;
}) {
  const [state, action, pending] = useActionState(submitCorrectionReport, {
    status: "idle",
  });

  if (state.status === "success") {
    return (
      <div className="rounded-2xl border border-primary bg-primary/5 p-6 text-center">
        <CheckCircle2 className="mx-auto mb-3 size-10 text-primary" />
        <h2 className="text-xl font-bold">ご報告ありがとうございました</h2>
        <p className="mt-2 text-sm text-muted-foreground">
          内容を確認し、必要に応じて表示を訂正します。
        </p>
      </div>
    );
  }

  return (
    <form
      action={action}
      className="space-y-5 rounded-2xl border bg-white p-5 shadow-sm sm:p-7"
    >
      <input type="hidden" name="billId" value={billId} />
      <input
        type="hidden"
        name="pageUrl"
        value={
          billId
            ? `https://mirai-gikai-tokorozawa.vercel.app/bills/${billId}`
            : "https://mirai-gikai-tokorozawa.vercel.app/"
        }
      />
      <div className="absolute -left-[10000px]" aria-hidden="true">
        <label htmlFor="website">ウェブサイト</label>
        <Input id="website" name="website" tabIndex={-1} autoComplete="off" />
      </div>
      <div>
        <label htmlFor="billName" className="mb-2 block text-sm font-bold">
          対象の議案・ページ
        </label>
        <Input
          id="billName"
          name="billName"
          defaultValue={billName || "サイト全体"}
          maxLength={300}
          required
        />
      </div>
      <div>
        <label htmlFor="reportType" className="mb-2 block text-sm font-bold">
          報告の種類
        </label>
        <select
          id="reportType"
          name="reportType"
          defaultValue="factual_error"
          className="h-10 w-full rounded-md border border-input bg-white px-3 text-sm"
        >
          <option value="factual_error">事実・数字の誤り</option>
          <option value="unclear">説明が分かりにくい</option>
          <option value="broken_link">リンクが開けない</option>
          <option value="other">その他</option>
        </select>
      </div>
      <div>
        <label htmlFor="location" className="mb-2 block text-sm font-bold">
          該当箇所（任意）
        </label>
        <Input
          id="location"
          name="location"
          maxLength={300}
          placeholder="例：概要の2段落目、予算額"
        />
      </div>
      <div>
        <label htmlFor="description" className="mb-2 block text-sm font-bold">
          内容
        </label>
        <Textarea
          id="description"
          name="description"
          minLength={10}
          maxLength={2000}
          rows={6}
          required
          placeholder="どの記載を、どのように直すべきか教えてください。"
        />
        <p className="mt-1 text-xs text-muted-foreground">
          10〜2000文字。氏名やメールアドレスは入力しないでください。
        </p>
      </div>
      <div>
        <label htmlFor="sourceUrl" className="mb-2 block text-sm font-bold">
          根拠となる資料のURL（任意）
        </label>
        <Input
          id="sourceUrl"
          name="sourceUrl"
          type="url"
          maxLength={500}
          placeholder="https://..."
        />
      </div>
      {state.status === "error" && (
        <p role="alert" className="text-sm font-bold text-destructive">
          {state.message}
        </p>
      )}
      <Button type="submit" disabled={pending} className="w-full">
        {pending ? "送信中…" : "この内容で報告する"}
      </Button>
      <p className="text-center text-xs text-muted-foreground">
        報告内容は一般公開されず、確認担当者だけが閲覧します。
      </p>
    </form>
  );
}
