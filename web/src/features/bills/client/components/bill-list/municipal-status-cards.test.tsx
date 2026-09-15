// @vitest-environment jsdom
import "@testing-library/jest-dom/vitest";
import { cleanup, render, screen } from "@testing-library/react";
import { afterEach, describe, expect, it } from "vitest";
import { createMockBill } from "@/app/dev/_lib/mock-data";
import { BillCard } from "./bill-card";
import { BillSearchCard } from "./bill-search-card";
import { CompactBillCard } from "./compact-bill-card";

afterEach(cleanup);

describe.each([
  BillCard,
  BillSearchCard,
  CompactBillCard,
])("%s の市議会結果", (Card) => {
  it("諮問への回答を可決と表示しない", () => {
    render(
      <Card
        bill={createMockBill({
          status: "enacted",
          status_note: "諮問第2号：回答する（2026年9月14日）",
        })}
      />
    );
    expect(screen.getByText("回答する")).toBeInTheDocument();
    expect(screen.queryByText("可決")).not.toBeInTheDocument();
  });
  it("決算特別委員会の審査を未確定と表示する", () => {
    render(
      <Card
        bill={createMockBill({
          status: "in_originating_house",
          status_note: "認定第1号：決算特別委員会に付託（最終結果未確認）",
        })}
      />
    );
    expect(screen.getByText("決算審査中")).toBeInTheDocument();
    expect(screen.queryByText("可決")).not.toBeInTheDocument();
  });
});

it("可決後も提出日を成立日と言い換えない", () => {
  render(
    <CompactBillCard
      bill={createMockBill({ status: "enacted", submitted_date: "2026-09-01" })}
    />
  );
  expect(screen.getByText("2026.9.1 提出")).toBeInTheDocument();
  expect(screen.queryByText(/成立/)).not.toBeInTheDocument();
});
