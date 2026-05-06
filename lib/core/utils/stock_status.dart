enum StockStatus { available, low, critical, outOfStock }

StockStatus getStockStatus({
  required int quantity,
  required int threshold,
}) {
  if (quantity <= 0) return StockStatus.outOfStock;
  if (quantity <= threshold ~/ 2) return StockStatus.critical;
  if (quantity <= threshold) return StockStatus.low;
  return StockStatus.available;
}
