import { Color, Icon } from "@raycast/api";
import type { DomainSnapshot, TransferProgress } from "./models";

const decimalUnits = ["B", "KB", "MB", "GB", "TB", "PB"];

export type ProgressRow = {
  label: string;
  fraction: number;
  value: string;
  target: string;
  accent: string;
};

export function formatBytes(bytes: number): string {
  if (!Number.isFinite(bytes)) {
    return "unknown";
  }

  let value = Math.max(0, bytes);
  let unitIndex = 0;

  while (value >= 1000 && unitIndex < decimalUnits.length - 1) {
    value /= 1000;
    unitIndex += 1;
  }

  const digits = value >= 10 || unitIndex === 0 ? 0 : 1;
  return `${value.toFixed(digits)} ${decimalUnits[unitIndex]}`;
}

export function formatPercent(fraction: number): string {
  if (!Number.isFinite(fraction)) {
    return "unknown";
  }

  return `${(fraction * 100).toFixed(1)}%`;
}

export function formatTransfer(progress: TransferProgress | null | undefined): string {
  if (!progress) {
    return "No active byte total";
  }

  return `${formatBytes(progress.completedBytes)} / ${formatBytes(progress.totalBytes)} (${formatPercent(transferFraction(progress))})`;
}

export function formatTransferPercent(progress: TransferProgress): string {
  return formatPercent(transferFraction(progress));
}

export function formatRemaining(progress: TransferProgress | null | undefined): string | undefined {
  if (!progress) {
    return undefined;
  }

  return `${formatBytes(progress.remainingBytes)} remaining`;
}

export function formatTransferProgressRow(label: string, progress: TransferProgress | null | undefined): ProgressRow {
  const accent = label === "Uploading" ? "#0A84FF" : "#30D158";

  if (!progress) {
    return {
      label,
      fraction: 1,
      value: "Idle",
      target: "No active byte total",
      accent,
    };
  }

  return {
    label,
    fraction: transferFraction(progress),
    value: formatBytes(progress.completedBytes),
    target: formatBytes(progress.totalBytes),
    accent,
  };
}

export function formatIndexingProgressRow(pending: number | null | undefined, total: number | null | undefined): ProgressRow {
  if (pending === null || pending === undefined || total === null || total === undefined) {
    return {
      label: "Indexing",
      fraction: 1,
      value: "Idle",
      target: "No index total",
      accent: "#FF9F0A",
    };
  }

  const completed = Math.max(total - pending, 0);
  return {
    label: "Indexing",
    fraction: indexingCompletionFraction(pending, total),
    value: `${formatCount(completed)} indexed`,
    target: `${formatCount(total)} total, ${formatCount(pending)} pending`,
    accent: "#FF9F0A",
  };
}

export function formatProgressMarkdown(row: ProgressRow): string {
  return [
    `**${row.label}** · ${row.value} (${row.target})`,
    `![${row.label} ${formatPercent(row.fraction)}](${progressSvgDataUri(row.fraction, row.accent)})`,
  ].join("\n");
}

export function formatObservedAt(value: string): string {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return value;
  }

  return date.toLocaleTimeString();
}

export function formatCount(value: number): string {
  return new Intl.NumberFormat().format(value);
}

function clamp01(value: number): number {
  if (!Number.isFinite(value)) {
    return 0;
  }

  return Math.min(1, Math.max(0, value));
}

function transferFraction(progress: TransferProgress): number {
  if (progress.totalBytes === 0 && progress.completedBytes === 0) {
    return 1;
  }

  return progress.fraction;
}

function indexingCompletionFraction(pending: number, total: number): number {
  if (total <= 0) {
    return pending <= 0 ? 1 : 0;
  }

  return (total - pending) / total;
}

function progressSvgDataUri(fraction: number, accent: string): string {
  const width = 560;
  const height = 28;
  const radius = 9;
  const padding = 2;
  const normalized = clamp01(fraction);
  const trackWidth = width - padding * 2;
  const fillWidth = Math.round(trackWidth * normalized);

  const svg = [
    `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">`,
    `<rect x="0" y="0" width="${width}" height="${height}" rx="${radius}" fill="#E7E7EA"/>`,
    fillWidth > 0
      ? `<rect x="${padding}" y="${padding}" width="${fillWidth}" height="${height - padding * 2}" rx="${radius - padding}" fill="${accent}"/>`
      : "",
    `<rect x="0.5" y="0.5" width="${width - 1}" height="${height - 1}" rx="${radius}" fill="none" stroke="#D1D1D6"/>`,
    "</svg>",
  ].join("");

  return `data:image/svg+xml;utf8,${encodeURIComponent(svg)}`;
}

export function domainStatusIcon(snapshot: DomainSnapshot) {
  if (snapshot.probeError) {
    return { source: Icon.Warning, tintColor: Color.Red };
  }

  if (snapshot.health.needsAuth) {
    return { source: Icon.Lock, tintColor: Color.Orange };
  }

  if (snapshot.upload || snapshot.download) {
    return { source: Icon.Cloud, tintColor: Color.Blue };
  }

  if (snapshot.health.isActive) {
    return { source: Icon.Circle, tintColor: Color.Green };
  }

  return { source: Icon.CheckCircle, tintColor: Color.Green };
}

export function statusAccessory(snapshot: DomainSnapshot): string {
  if (snapshot.probeError) {
    return "Error";
  }

  const activeTransfers = [snapshot.upload, snapshot.download].filter(Boolean).length;
  if (activeTransfers > 0) {
    return activeTransfers === 1 ? "1 transfer" : `${activeTransfers} transfers`;
  }

  if (snapshot.health.needsAuth) {
    return "Needs sign-in";
  }

  if (snapshot.health.isActive) {
    return "Active";
  }

  return "Idle";
}
