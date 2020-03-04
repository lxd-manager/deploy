docker-compose exec -T database pg_dump ctapi -U ctapi > backup/$(date +"%Y-%m-%d_%H-%M")-databases.sql
