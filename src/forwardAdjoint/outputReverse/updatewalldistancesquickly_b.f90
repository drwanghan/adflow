   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.10 (r5363) -  9 Sep 2014 09:53
   !
   !  Differentiation of updatewalldistancesquickly in reverse (adjoint) mode (with options i4 dr8 r8 noISIZE):
   !   gradient     of useful results: *x *d2wall
   !   with respect to varying inputs: *x *xsurf
   !   Plus diff mem management of: x:in d2wall:in xsurf:in
   SUBROUTINE UPDATEWALLDISTANCESQUICKLY_B(nn, level, sps)
   ! This is the actual update routine that uses xSurf. It is done on
   ! block-level-sps basis.  This is the used to update the wall
   ! distance. Most importantly, this routine is included in the
   ! reverse mode AD routines, but NOT the forward mode. Since it is
   ! done on a per-block basis, it is assumed that the required block
   ! pointers are already set. 
   USE BLOCKPOINTERS
   USE WALLDISTANCEDATA
   IMPLICIT NONE
   ! Subroutine arguments
   INTEGER(kind=inttype) :: nn, level, sps
   ! Local Variables
   INTEGER(kind=inttype) :: i, j, k, faceid
   REAL(kind=realtype) :: xp(3), xc(3), u, v
   REAL(kind=realtype) :: xpd(3), xcd(3)
   INTRINSIC SQRT
   REAL(kind=realtype) :: tempd
   REAL(kind=realtype) :: tempd5
   REAL(kind=realtype) :: tempd4
   REAL(kind=realtype) :: tempd3
   REAL(kind=realtype) :: tempd2
   REAL(kind=realtype) :: tempd1
   REAL(kind=realtype) :: tempd0
   DO k=2,kl
   DO j=2,jl
   DO i=2,il
   ! Extract elemID and u-v position for the association of
   ! this cell:
   faceid = flowdoms(nn, level, sps)%elemid(i, j, k)
   u = flowdoms(nn, level, sps)%uv(1, i, j, k)
   v = flowdoms(nn, level, sps)%uv(2, i, j, k)
   ! Now we have the 4 corners, use bi-linear shape
   ! functions o to get target: (CCW ordering remember!)
   CALL PUSHREAL8ARRAY(xp, 3)
   xp(:) = (one-u)*(one-v)*xsurf(12*(faceid-1)+1:12*(faceid-1)+3) +&
   &         u*(one-v)*xsurf(12*(faceid-1)+4:12*(faceid-1)+6) + u*v*xsurf(&
   &         12*(faceid-1)+7:12*(faceid-1)+9) + (one-u)*v*xsurf(12*(faceid-&
   &         1)+10:12*(faceid-1)+12)
   ! Get the cell center
   CALL PUSHREAL8(xc(1))
   xc(1) = eighth*(x(i-1, j-1, k-1, 1)+x(i, j-1, k-1, 1)+x(i-1, j, &
   &         k-1, 1)+x(i, j, k-1, 1)+x(i-1, j-1, k, 1)+x(i, j-1, k, 1)+x(i-&
   &         1, j, k, 1)+x(i, j, k, 1))
   CALL PUSHREAL8(xc(2))
   xc(2) = eighth*(x(i-1, j-1, k-1, 2)+x(i, j-1, k-1, 2)+x(i-1, j, &
   &         k-1, 2)+x(i, j, k-1, 2)+x(i-1, j-1, k, 2)+x(i, j-1, k, 2)+x(i-&
   &         1, j, k, 2)+x(i, j, k, 2))
   CALL PUSHREAL8(xc(3))
   xc(3) = eighth*(x(i-1, j-1, k-1, 3)+x(i, j-1, k-1, 3)+x(i-1, j, &
   &         k-1, 3)+x(i, j, k-1, 3)+x(i-1, j-1, k, 3)+x(i, j-1, k, 3)+x(i-&
   &         1, j, k, 3)+x(i, j, k, 3))
   ! Now we have the two points...just take the norm of the
   ! distance between them
   END DO
   END DO
   END DO
   xsurfd = 0.0_8
   xcd = 0.0_8
   DO k=kl,2,-1
   DO j=jl,2,-1
   DO i=il,2,-1
   xpd = 0.0_8
   IF ((xc(1)-xp(1))**2 + (xc(2)-xp(2))**2 + (xc(3)-xp(3))**2 .EQ. &
   &           0.0_8) THEN
   tempd = 0.0
   ELSE
   tempd = d2walld(i, j, k)/(2.0*SQRT((xc(1)-xp(1))**2+(xc(2)-xp(&
   &           2))**2+(xc(3)-xp(3))**2))
   END IF
   tempd0 = 2*(xc(1)-xp(1))*tempd
   tempd1 = 2*(xc(2)-xp(2))*tempd
   tempd2 = 2*(xc(3)-xp(3))*tempd
   xcd(1) = xcd(1) + tempd0
   xpd(1) = xpd(1) - tempd0
   xcd(2) = xcd(2) + tempd1
   xpd(2) = xpd(2) - tempd1
   xcd(3) = xcd(3) + tempd2
   xpd(3) = xpd(3) - tempd2
   d2walld(i, j, k) = 0.0_8
   CALL POPREAL8(xc(3))
   tempd3 = eighth*xcd(3)
   xd(i-1, j-1, k-1, 3) = xd(i-1, j-1, k-1, 3) + tempd3
   xd(i, j-1, k-1, 3) = xd(i, j-1, k-1, 3) + tempd3
   xd(i-1, j, k-1, 3) = xd(i-1, j, k-1, 3) + tempd3
   xd(i, j, k-1, 3) = xd(i, j, k-1, 3) + tempd3
   xd(i-1, j-1, k, 3) = xd(i-1, j-1, k, 3) + tempd3
   xd(i, j-1, k, 3) = xd(i, j-1, k, 3) + tempd3
   xd(i-1, j, k, 3) = xd(i-1, j, k, 3) + tempd3
   xd(i, j, k, 3) = xd(i, j, k, 3) + tempd3
   xcd(3) = 0.0_8
   CALL POPREAL8(xc(2))
   tempd4 = eighth*xcd(2)
   xd(i-1, j-1, k-1, 2) = xd(i-1, j-1, k-1, 2) + tempd4
   xd(i, j-1, k-1, 2) = xd(i, j-1, k-1, 2) + tempd4
   xd(i-1, j, k-1, 2) = xd(i-1, j, k-1, 2) + tempd4
   xd(i, j, k-1, 2) = xd(i, j, k-1, 2) + tempd4
   xd(i-1, j-1, k, 2) = xd(i-1, j-1, k, 2) + tempd4
   xd(i, j-1, k, 2) = xd(i, j-1, k, 2) + tempd4
   xd(i-1, j, k, 2) = xd(i-1, j, k, 2) + tempd4
   xd(i, j, k, 2) = xd(i, j, k, 2) + tempd4
   xcd(2) = 0.0_8
   CALL POPREAL8(xc(1))
   tempd5 = eighth*xcd(1)
   xd(i-1, j-1, k-1, 1) = xd(i-1, j-1, k-1, 1) + tempd5
   xd(i, j-1, k-1, 1) = xd(i, j-1, k-1, 1) + tempd5
   xd(i-1, j, k-1, 1) = xd(i-1, j, k-1, 1) + tempd5
   xd(i, j, k-1, 1) = xd(i, j, k-1, 1) + tempd5
   xd(i-1, j-1, k, 1) = xd(i-1, j-1, k, 1) + tempd5
   xd(i, j-1, k, 1) = xd(i, j-1, k, 1) + tempd5
   xd(i-1, j, k, 1) = xd(i-1, j, k, 1) + tempd5
   xd(i, j, k, 1) = xd(i, j, k, 1) + tempd5
   xcd(1) = 0.0_8
   u = flowdoms(nn, level, sps)%uv(1, i, j, k)
   v = flowdoms(nn, level, sps)%uv(2, i, j, k)
   faceid = flowdoms(nn, level, sps)%elemid(i, j, k)
   CALL POPREAL8ARRAY(xp, 3)
   xsurfd(12*(faceid-1)+1:12*(faceid-1)+3) = xsurfd(12*(faceid-1)+1&
   &         :12*(faceid-1)+3) + (one-u)*(one-v)*xpd
   xsurfd(12*(faceid-1)+4:12*(faceid-1)+6) = xsurfd(12*(faceid-1)+4&
   &         :12*(faceid-1)+6) + u*(one-v)*xpd
   xsurfd(12*(faceid-1)+7:12*(faceid-1)+9) = xsurfd(12*(faceid-1)+7&
   &         :12*(faceid-1)+9) + u*v*xpd
   xsurfd(12*(faceid-1)+10:12*(faceid-1)+12) = xsurfd(12*(faceid-1)&
   &         +10:12*(faceid-1)+12) + (one-u)*v*xpd
   END DO
   END DO
   END DO
   END SUBROUTINE UPDATEWALLDISTANCESQUICKLY_B
