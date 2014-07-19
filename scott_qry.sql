select d.dname, e.empno, e.ename, e.sal
from scott.emp e, scott.dept d
where d.deptno=e.deptno and sal > 2500;
