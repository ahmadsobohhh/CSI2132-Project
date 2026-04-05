--
-- 2c) Database queries
--

-- Query 1 (availability by filters): available rooms in a date range with optional hotel/chain/area filters.
-- Uses NOT EXISTS to exclude overlapping active bookings and in-progress rentings.
SELECT
    h.name AS hotel_name,
    h.city,
    h.province,
    r.hotel_id,
    r.room_number,
    r.capacity,
    r.price,
    r.view_type
FROM locations.room r
JOIN locations.hotel h ON h.hotel_id = r.hotel_id
WHERE h.chain_id = 1
  AND h.city = 'Montréal'
  AND r.capacity >= 2
  AND r.price <= 300
  AND NOT EXISTS (
      SELECT 1
      FROM records.booking_records b
      WHERE b.hotel_id = r.hotel_id
        AND b.room_number = r.room_number
        AND b.status = 'Active'
        AND b.start_date < DATE '2026-04-10'
        AND b.end_date > DATE '2026-04-05'
  )
  AND NOT EXISTS (
      SELECT 1
      FROM records.renting_records rr
      WHERE rr.hotel_id = r.hotel_id
        AND rr.room_number = r.room_number
        AND rr.status = 'Checked-In'
        AND rr.start_date < DATE '2026-04-10'
        AND rr.end_date > DATE '2026-04-05'
  )
ORDER BY r.price, r.capacity DESC;


-- Query 2 (aggregation): number of rooms and average price per hotel in each city.
SELECT
    h.city,
    h.name AS hotel_name,
    COUNT(*) AS total_rooms,
    ROUND(AVG(r.price), 2) AS avg_room_price,
    MAX(r.capacity) AS max_capacity
FROM locations.hotel h
JOIN locations.room r ON r.hotel_id = h.hotel_id
GROUP BY h.city, h.name
ORDER BY h.city, total_rooms DESC;


-- Query 3 (nested query): customers who have at least one booking at hotels rated above the global average rating.
SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name
FROM people.customer c
WHERE c.customer_id IN (
    SELECT b.customer_id
    FROM records.booking_records b
    JOIN locations.hotel h ON h.hotel_id = b.hotel_id
    WHERE h.rating > (
        SELECT AVG(rating)
        FROM locations.hotel
        WHERE rating IS NOT NULL
    )
)
ORDER BY c.customer_id;


-- Query 4 (operational report): employee check-ins/rentings volume and revenue collected.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    COUNT(rr.renting_id) AS total_rentings,
    COALESCE(SUM(rr.payment_amount), 0) AS total_payments
FROM people.employee e
LEFT JOIN records.renting_records rr ON rr.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY total_rentings DESC, total_payments DESC;


-- Query 5 (renting archive): archived rentings by hotel with aggregated archived revenue.
SELECT
    ra.hotel_name_snap,
    COUNT(*) AS archived_rentings,
    COALESCE(SUM(ra.payment_amount_snap), 0) AS archived_revenue,
    MIN(ra.start_date_snap) AS first_archived_start,
    MAX(ra.end_date_snap) AS last_archived_end
FROM records.renting_archive ra
GROUP BY ra.hotel_name_snap
ORDER BY archived_rentings DESC, archived_revenue DESC;
