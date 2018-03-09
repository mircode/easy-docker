
https://www.bilibili.com/video/av13397616/?from=search&seid=8190051497835067040#page=11

926850
!connect jdbc:calcite:model=target/test-classes/model.json admin admin
!tables
!columns
!describe
select * from emps;
select d.name,count(*) from emps as e join depts as d on e.deptno = d.deptno  group by d.name;
values char_length('hello, ' || 'world!');

!connect jdbc:calcite:model=elasticsearch-zips-model.json admin admin


Welcome to Pivot!
You have connected to an evaluation server which will expire in 30 days. If you already have a license, please install it now. To obtain a license, contact sales@imply.io.

We hope you enjoy your trial!

