#
# 1. Add some logs
#

`curl -X POST \
  http://127.0.0.1:8080/logs/new \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -H 'Postman-Token: 6542e42d-4173-4d0f-a1dc-b61cceb736ec' \
  -d '{
	"user": "test_user1@company.com",
	"task": "test_task1",
	"start": 1527354210,
	"end": 1527355000
}'`

`curl -X POST \
  http://127.0.0.1:8080/logs/new \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -H 'Postman-Token: 6542e42d-4173-4d0f-a1dc-b61cceb736ec' \
  -d '{
	"user": "test_user1@company.com",
	"task": "test_task2",
	"start": 1527355210,
	"end": 1527355900
}'`

#
# 2. Commit to blockchain
#

`curl -X POST \
  http://127.0.0.1:8080/logs/commit \
  -H 'Cache-Control: no-cache' \
  -H 'Postman-Token: 816743ae-58c1-4d89-912f-65f8ab4ec84f'`

#
# 3. Verify they exist unchanged
#

`curl -X GET \
  http://127.0.0.1:8080/logs/validate/hashid/0 \
  -H 'Cache-Control: no-cache' \
  -H 'Postman-Token: 0f8ce38f-a84b-4d75-9dc3-fa7f3f1ce780'`


#
# 4. Add another log
#

`curl -X POST \
  http://127.0.0.1:8080/logs/new \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -H 'Postman-Token: 6542e42d-4173-4d0f-a1dc-b61cceb736ec' \
  -d '{
	"user": "test_user1@company.com",
	"task": "test_task1",
	"start": 1527354210,
	"end": 1527355000
}'`

#
# 5. Commit to blockchain
#

`curl -X POST \
  http://127.0.0.1:8080/logs/commit \
  -H 'Cache-Control: no-cache' \
  -H 'Postman-Token: 816743ae-58c1-4d89-912f-65f8ab4ec84f'`


#
# 6. Manually change the lastest log's end time in the database
#

`mysql -u root -proot -D scotchbox -e "UPDATE logs SET end = '1527355002' WHERE id = 3;"`

#
# 7. Verify that the hashes don't match anymore
#

`curl -X GET \
  http://127.0.0.1:8080/logs/validate/hashid/1 \
  -H 'Cache-Control: no-cache' \
  -H 'Postman-Token: 0f8ce38f-a84b-4d75-9dc3-fa7f3f1ce780'`