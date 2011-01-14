   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.4 (r3375) - 10 Feb 2010 15:08
   !
   !  Differentiation of bcfarfieldnkpc in forward (tangent) mode:
   !   variations   of useful results: padj wadj
   !   with respect to varying inputs: padj wadj
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          bcFarfieldAdj.f90                               *
   !      * Author:        Edwin van der Weide                             *
   !      *                Seongim Choi,C.A.(Sandy) Mader                  *
   !      * Starting date: 03-21-2006                                      *
   !      * Last modified: 04-23-2008                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE BCFARFIELDNKPC_D(secondhalo, winfadj, pinfcorradj, wadj, &
   &  wadjd, padj, padjd, siadj, sjadj, skadj, normadj, rfaceadj, icell, &
   &  jcell, kcell, nn, level, sps, sps2)
   USE FLOWVARREFSTATE
   USE BLOCKPOINTERS, ONLY : nbocos, bctype
   USE INPUTTIMESPECTRAL
   USE BCTYPES
   USE CONSTANTS
   USE ITERATION
   IMPLICIT NONE
   !
   !      ******************************************************************
   !      *                                                                *
   !      * bcFarfieldAdj applies the farfield boundary condition to       *
   !      * subface nn of the block to which the pointers in blockPointers *
   !      * currently point.                                               *
   !      *                                                                *
   !      ******************************************************************
   !
   ! irho,ivx,ivy,ivz
   ! gammaInf, wInf, pInfCorr
   !nIntervalTimespectral
   !
   !      Subroutine arguments.
   !
   ! it's not needed anymore w/ normAdj
   INTEGER(kind=inttype) :: nn, level, sps, sps2
   !       integer(kind=intType), intent(in) :: icBeg, icEnd, jcBeg, jcEnd
   !       integer(kind=intType), intent(in) :: iOffset, jOffset
   INTEGER(kind=inttype) :: icell, jcell, kcell
   INTEGER(kind=inttype) :: isbeg, jsbeg, ksbeg, isend, jsend, ksend
   INTEGER(kind=inttype) :: ibbeg, jbbeg, kbbeg, ibend, jbend, kbend
   INTEGER(kind=inttype) :: icbeg, jcbeg, kcbeg, icend, jcend, kcend
   INTEGER(kind=inttype) :: ioffset, joffset, koffset
   REAL(kind=realtype), DIMENSION(-2:2, -2:2, -2:2) :: rlvadj, revadj
   REAL(kind=realtype), DIMENSION(-2:2, -2:2) :: rlvadj1, rlvadj2
   REAL(kind=realtype), DIMENSION(-2:2, -2:2) :: revadj1, revadj2
   REAL(kind=realtype), DIMENSION(nw), INTENT(IN) :: winfadj
   !  real(kind=realType), dimension(-2:2,-2:2,-2:2,3), intent(in) :: &
   !       siAdj, sjAdj, skAdj
   REAL(kind=realtype), DIMENSION(-3:2, -3:2, -3:2, 3, &
   &  ntimeintervalsspectral), INTENT(IN) :: siadj, sjadj, skadj
   REAL(kind=realtype), DIMENSION(nbocos, -2:2, -2:2, 3, &
   &  ntimeintervalsspectral), INTENT(IN) :: normadj
   REAL(kind=realtype), DIMENSION(nbocos, -2:2, -2:2, &
   &  ntimeintervalsspectral), INTENT(IN) :: rfaceadj
   REAL(kind=realtype), DIMENSION(-2:2, -2:2, -2:2, nw, &
   &  ntimeintervalsspectral), INTENT(IN) :: wadj
   REAL(kind=realtype), DIMENSION(-2:2, -2:2, -2:2, nw, &
   &  ntimeintervalsspectral), INTENT(IN) :: wadjd
   REAL(kind=realtype), DIMENSION(-2:2, -2:2, -2:2, &
   &  ntimeintervalsspectral), INTENT(IN) :: padj
   REAL(kind=realtype), DIMENSION(-2:2, -2:2, -2:2, &
   &  ntimeintervalsspectral), INTENT(IN) :: padjd
   REAL(kind=realtype) :: pinfcorradj
   !logical, intent(in) :: secondHalo
   LOGICAL :: secondhalo
   REAL(kind=realtype), DIMENSION(-2:2, -2:2, nw) :: wadj0, wadj1
   REAL(kind=realtype), DIMENSION(-2:2, -2:2, nw) :: wadj0d, wadj1d
   REAL(kind=realtype), DIMENSION(-2:2, -2:2, nw) :: wadj2, wadj3
   REAL(kind=realtype), DIMENSION(-2:2, -2:2, nw) :: wadj2d, wadj3d
   REAL(kind=realtype), DIMENSION(-2:2, -2:2) :: padj0, padj1
   REAL(kind=realtype), DIMENSION(-2:2, -2:2) :: padj0d, padj1d
   REAL(kind=realtype), DIMENSION(-2:2, -2:2) :: padj2, padj3
   REAL(kind=realtype), DIMENSION(-2:2, -2:2) :: padj2d, padj3d
   !real(kind=realType), dimension(nBocos,-2:2,-2:2,3), intent(in) :: normAdj
   !
   !      Local variables.
   !
   INTEGER(kind=inttype) :: i, j, l, ii, jj, nnbcs
   REAL(kind=realtype) :: nnx, nny, nnz
   REAL(kind=realtype) :: gm1, ovgm1, gm53, factk, ac1, ac2
   REAL(kind=realtype) :: ac1d, ac2d
   REAL(kind=realtype) :: r0, u0, v0, w0, qn0, vn0, c0, s0
   REAL(kind=realtype) :: re, ue, ve, we, qne, ce
   REAL(kind=realtype) :: red, ued, ved, wed, qned, ced
   REAL(kind=realtype) :: qnf, cf, uf, vf, wf, sf, cc, qq
   REAL(kind=realtype) :: qnfd, cfd, ufd, vfd, wfd, sfd, ccd
   REAL(kind=realtype) :: rface
   LOGICAL :: computebc
   REAL(kind=realtype) :: arg1
   REAL(kind=realtype) :: arg1d
   REAL(kind=realtype) :: pwr1
   REAL(kind=realtype) :: pwr1d
   REAL(kind=realtype) :: pwx1
   REAL(kind=realtype) :: pwx1d
   INTRINSIC SQRT
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Begin execution                                                *
   !      *                                                                *
   !      ******************************************************************
   !
   ! Some constants needed to compute the riemann invariants.
   gm1 = gammainf - one
   ovgm1 = one/gm1
   gm53 = gammainf - five*third
   factk = -(ovgm1*gm53)
   ! Compute the three velocity components, the speed of sound and
   ! the entropy of the free stream.
   r0 = one/winfadj(irho)
   u0 = winfadj(ivx)
   v0 = winfadj(ivy)
   w0 = winfadj(ivz)
   arg1 = gammainf*pinfcorradj*r0
   c0 = SQRT(arg1)
   pwr1 = winfadj(irho)**gammainf
   s0 = pwr1/pinfcorradj
   padj0d = 0.0
   padj1d = 0.0
   padj2d = 0.0
   wadj0d = 0.0
   wadj1d = 0.0
   wadj2d = 0.0
   ! Loop over the boundary condition subfaces of this block.
   bocos:DO nnbcs=1,nbocos
   CALL CHECKOVERLAPNKPC(nnbcs, icell, jcell, kcell, isbeg, jsbeg, &
   &                       ksbeg, isend, jsend, ksend, ibbeg, jbbeg, kbbeg, &
   &                       ibend, jbend, kbend, computebc)
   IF (computebc) THEN
   ! Check for farfield boundary conditions.
   IF (bctype(nnbcs) .EQ. farfield) THEN
   wadj3d = 0.0
   padj3d = 0.0
   CALL EXTRACTBCSTATESNKPC_D(nnbcs, wadj, wadjd, padj, padjd, &
   &                             wadj0, wadj0d, wadj1, wadj1d, wadj2, wadj2d&
   &                             , wadj3, wadj3d, padj0, padj0d, padj1, &
   &                             padj1d, padj2, padj2d, padj3, padj3d, &
   &                             rlvadj, revadj, rlvadj1, rlvadj2, revadj1, &
   &                             revadj2, ioffset, joffset, koffset, icell, &
   &                             jcell, kcell, isbeg, jsbeg, ksbeg, isend, &
   &                             jsend, ksend, ibbeg, jbbeg, kbbeg, ibend, &
   &                             jbend, kbend, icbeg, jcbeg, icend, jcend, &
   &                             secondhalo, nn, level, sps, sps2)
   ! Loop over the generic subface to set the state in the
   ! halo cells.
   DO j=jcbeg,jcend
   DO i=icbeg,icend
   ii = i - ioffset
   jj = j - joffset
   !BCData(nn)%rface(i,j)
   rface = rfaceadj(nnbcs, ii, jj, sps2)
   ! Store the three components of the unit normal a
   ! bit easier.
   nnx = normadj(nnbcs, ii, jj, 1, sps2)
   nny = normadj(nnbcs, ii, jj, 2, sps2)
   nnz = normadj(nnbcs, ii, jj, 3, sps2)
   ! Compute the normal velocity of the free stream and
   ! substract the normal velocity of the mesh.
   qn0 = u0*nnx + v0*nny + w0*nnz
   vn0 = qn0 - rface
   ! Compute the three velocity components, the normal
   ! velocity and the speed of sound of the current state
   ! in the internal cell.
   red = -(one*wadj2d(ii, jj, irho)/wadj2(ii, jj, irho)**2)
   re = one/wadj2(ii, jj, irho)
   ued = wadj2d(ii, jj, ivx)
   ue = wadj2(ii, jj, ivx)
   ved = wadj2d(ii, jj, ivy)
   ve = wadj2(ii, jj, ivy)
   wed = wadj2d(ii, jj, ivz)
   we = wadj2(ii, jj, ivz)
   qned = nnx*ued + nny*ved + nnz*wed
   qne = ue*nnx + ve*nny + we*nnz
   arg1d = gammainf*(padj2d(ii, jj)*re+padj2(ii, jj)*red)
   arg1 = gammainf*padj2(ii, jj)*re
   IF (arg1 .EQ. 0.0) THEN
   ced = 0.0
   ELSE
   ced = arg1d/(2.0*SQRT(arg1))
   END IF
   ce = SQRT(arg1)
   ! Compute the new values of the riemann invariants in
   ! the halo cell. Either the value in the internal cell
   ! is taken (positive sign of the corresponding
   ! eigenvalue) or the free stream value is taken
   ! (otherwise).
   IF (vn0 .GT. -c0) THEN
   ! Outflow or subsonic inflow.
   ac1d = qned + two*ovgm1*ced
   ac1 = qne + two*ovgm1*ce
   ELSE
   ! Supersonic inflow.
   ac1 = qn0 + two*ovgm1*c0
   ac1d = 0.0
   END IF
   IF (vn0 .GT. c0) THEN
   ! Supersonic outflow.
   ac2d = qned - two*ovgm1*ced
   ac2 = qne - two*ovgm1*ce
   ELSE
   ! Inflow or subsonic outflow.
   ac2 = qn0 - two*ovgm1*c0
   ac2d = 0.0
   END IF
   qnfd = half*(ac1d+ac2d)
   qnf = half*(ac1+ac2)
   cfd = fourth*gm1*(ac1d-ac2d)
   cf = fourth*(ac1-ac2)*gm1
   IF (vn0 .GT. zero) THEN
   ! Outflow.
   ufd = ued + nnx*(qnfd-qned)
   uf = ue + (qnf-qne)*nnx
   vfd = ved + nny*(qnfd-qned)
   vf = ve + (qnf-qne)*nny
   wfd = wed + nnz*(qnfd-qned)
   wf = we + (qnf-qne)*nnz
   IF (wadj2(ii, jj, irho) .GT. 0.0 .OR. (wadj2(ii, jj, irho)&
   &                  .LT. 0.0 .AND. gammainf .EQ. INT(gammainf))) THEN
   pwr1d = gammainf*wadj2(ii, jj, irho)**(gammainf-1)*&
   &                  wadj2d(ii, jj, irho)
   ELSE IF (wadj2(ii, jj, irho) .EQ. 0.0 .AND. gammainf .EQ. &
   &                  1.0) THEN
   pwr1d = wadj2d(ii, jj, irho)
   ELSE
   pwr1d = 0.0
   END IF
   pwr1 = wadj2(ii, jj, irho)**gammainf
   sfd = (pwr1d*padj2(ii, jj)-pwr1*padj2d(ii, jj))/padj2(ii, &
   &                jj)**2
   sf = pwr1/padj2(ii, jj)
   DO l=nt1mg,nt2mg
   wadj1d(ii, jj, l) = wadj2d(ii, jj, l)
   wadj1(ii, jj, l) = wadj2(ii, jj, l)
   END DO
   ELSE
   ! Inflow
   ufd = nnx*qnfd
   uf = u0 + (qnf-qn0)*nnx
   vfd = nny*qnfd
   vf = v0 + (qnf-qn0)*nny
   wfd = nnz*qnfd
   wf = w0 + (qnf-qn0)*nnz
   sf = s0
   DO l=nt1mg,nt2mg
   wadj1d(ii, jj, l) = 0.0
   wadj1(ii, jj, l) = winfadj(l)
   END DO
   sfd = 0.0
   END IF
   ! Compute the density, velocity and pressure in the
   ! halo cell.
   ccd = (cfd*cf+cf*cfd)/gammainf
   cc = cf*cf/gammainf
   qq = uf*uf + vf*vf + wf*wf
   pwx1d = sfd*cc + sf*ccd
   pwx1 = sf*cc
   IF (pwx1 .GT. 0.0 .OR. (pwx1 .LT. 0.0 .AND. ovgm1 .EQ. INT(&
   &                ovgm1))) THEN
   wadj1d(ii, jj, irho) = ovgm1*pwx1**(ovgm1-1)*pwx1d
   ELSE IF (pwx1 .EQ. 0.0 .AND. ovgm1 .EQ. 1.0) THEN
   wadj1d(ii, jj, irho) = pwx1d
   ELSE
   wadj1d(ii, jj, irho) = 0.0
   END IF
   wadj1(ii, jj, irho) = pwx1**ovgm1
   wadj1d(ii, jj, ivx) = ufd
   wadj1(ii, jj, ivx) = uf
   wadj1d(ii, jj, ivy) = vfd
   wadj1(ii, jj, ivy) = vf
   wadj1d(ii, jj, ivz) = wfd
   wadj1(ii, jj, ivz) = wf
   padj1d(ii, jj) = wadj1d(ii, jj, irho)*cc + wadj1(ii, jj, &
   &              irho)*ccd
   padj1(ii, jj) = wadj1(ii, jj, irho)*cc
   ! Compute the total energy.
   wadj1d(ii, jj, irhoe) = ovgm1*padj1d(ii, jj) + half*(wadj1d(&
   &              ii, jj, irho)*(uf**2+vf**2+wf**2)+wadj1(ii, jj, irho)*(2*&
   &              uf*ufd+2*vf*vfd+2*wf*wfd))
   wadj1(ii, jj, irhoe) = ovgm1*padj1(ii, jj) + half*wadj1(ii, &
   &              jj, irho)*(uf**2+vf**2+wf**2)
   IF (kpresent) THEN
   wadj1d(ii, jj, irhoe) = wadj1d(ii, jj, irhoe) - factk*(&
   &                wadj1d(ii, jj, irho)*wadj1(ii, jj, itu1)+wadj1(ii, jj, &
   &                irho)*wadj1d(ii, jj, itu1))
   wadj1(ii, jj, irhoe) = wadj1(ii, jj, irhoe) - factk*wadj1(&
   &                ii, jj, irho)*wadj1(ii, jj, itu1)
   END IF
   END DO
   END DO
   !
   !        Input the viscous effects - rlv1(), and rev1()
   !
   ! Extrapolate the state vectors in case a second halo
   ! is needed.
   IF (secondhalo) CALL EXTRAPOLATE2NDHALONKPC_D(nnbcs, icbeg, &
   &                                                icend, jcbeg, jcend, &
   &                                                ioffset, joffset, wadj0&
   &                                                , wadj0d, wadj1, wadj1d&
   &                                                , wadj2, wadj2d, padj0, &
   &                                                padj0d, padj1, padj1d, &
   &                                                padj2, padj2d)
   CALL REPLACEBCSTATESNKPC_D(nnbcs, wadj0, wadj0d, wadj1, wadj1d, &
   &                             wadj2, wadj3, padj0, padj0d, padj1, padj1d&
   &                             , padj2, padj3, rlvadj1, rlvadj2, revadj1, &
   &                             revadj2, icell, jcell, kcell, wadj, wadjd, &
   &                             padj, padjd, rlvadj, revadj, secondhalo, nn&
   &                             , level, sps, sps2)
   END IF
   END IF
   END DO bocos
   END SUBROUTINE BCFARFIELDNKPC_D