CREATE TABLE
md_water_services.well_pollution_copy
AS (
SELECT
*
FROM
md_water_services.well_pollution
);

use md_water_services;

UPDATE
well_pollution_copy
SET
description = 'Bacteria
:
E
. coli'

WHERE
description = 'Clean Bacteria
:
E
. coli';

SELECT
*
FROM
well_pollution_copy
WHERE
description LIKE "Clean_%"
OR (results = "Clean" AND biological > 0.01);

UPDATE
well_pollution_copy
SET
description = 'Bacteria

: Giardia Lamblia'

WHERE
description = 'Clean Bacteria

: Giardia Lamblia';

UPDATE
well_pollution_copy
SET
results = 'Contaminated

: Biological'

WHERE
biological > 0.01 AND results = 'Clean';

UPDATE
well_pollution_copy
SET
description = 'Bacteria: E. coli'
WHERE
description = 'Clean Bacteria: E. coli';
UPDATE
well_pollution_copy
SET
description = 'Bacteria: Giardia Lamblia'
WHERE
description = 'Clean Bacteria: Giardia Lamblia';
UPDATE
well_pollution_copy
SET
results = 'Contaminated: Biological'
WHERE
biological > 0.01 AND results = 'Clean';


