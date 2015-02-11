!        generated by tapenade     (inria, tropics team)
!  tapenade 3.10 (r5363) -  9 sep 2014 09:53
!
!  differentiation of setflowinfinitystate in reverse (adjoint) mode (with options i4 dr8 r8 noisize):
!   gradient     of useful results: gammainf pinf rhoinf tref winf
!                pinfcorr rgas veldirfreestream machcoef
!   with respect to varying inputs: gammainf pinf rhoinf tref muinf
!                uinf rgas veldirfreestream machcoef
!
!      ******************************************************************
!      *                                                                *
!      * file:          setflowinfinitystate.f90                        *
!      * author:        edwin van der weide, georgi kalitzin            *
!      * starting date: 02-21-2003                                      *
!      * last modified: 06-12-2005                                      *
!      *                                                                *
!      ******************************************************************
!
subroutine setflowinfinitystate_b()
!
!      ******************************************************************
!      *                                                                *
!      * setflowinfinitystate sets the free stream state vector of      *
!      * the flow variables. if nothing is specified for each of the    *
!      * farfield boundaries, these values will be taken to define the  *
!      * free stream.                                                   *
!      *                                                                *
!      ******************************************************************
!
  use constants
  use flowvarrefstate
  use inputphysics
  use paramturb
  implicit none
!
!      local variables
!
  integer(kind=inttype) :: ierr
  real(kind=realtype) :: nuinf, ktmp, uinf2
  real(kind=realtype) :: nuinfd, ktmpd, uinf2d
!
!      function definition
!
  real(kind=realtype) :: sanuknowneddyratio
! dummy parameters
  real(kind=realtype) :: vinf, zinf
  real(kind=realtype) :: vinfd, zinfd
  real(kind=realtype) :: tmp
  real(kind=realtype) :: tmp0
  real(kind=realtype) :: tmp1
  real(kind=realtype) :: tmp2
  integer :: branch
  real(kind=realtype) :: tmpd
  real(kind=realtype) :: tempd
  real(kind=realtype) :: tempd3
  real(kind=realtype) :: tempd2
  real(kind=realtype) :: tempd1
  real(kind=realtype) :: tempd0
  real(kind=realtype) :: tmpd2
  real(kind=realtype) :: tmpd1
  real(kind=realtype) :: tmpd0
  real(kind=realtype) :: temp
!
!      ******************************************************************
!      *                                                                *
!      * begin execution                                                *
!      *                                                                *
!      ******************************************************************
!
! compute the velocity squared based on machcoef;
! needed for the initialization of the turbulent energy,
! especially for moving geometries.
  uinf2 = machcoef*machcoef*gammainf*pinf/rhoinf
! allocate the memory for winf.
! zero out the winf first
  winf(:) = zero
! set the reference value of the flow variables, except the total
! energy. this will be computed at the end of this routine.
  winf(irho) = rhoinf
  winf(ivx) = uinf*veldirfreestream(1)
  winf(ivy) = uinf*veldirfreestream(2)
  winf(ivz) = uinf*veldirfreestream(3)
! set the turbulent variables if transport variables are
! to be solved.
  if (equations .eq. ransequations) then
    nuinf = muinf/rhoinf
    select case  (turbmodel) 
    case (spalartallmaras, spalartallmarasedwards) 
      winf(itu1) = sanuknowneddyratio(eddyvisinfratio, nuinf)
      call pushcontrol3b(1)
    case (komegawilcox, komegamodified, mentersst) 
!   winf(itu1) = 1.341946*nuinf   ! eddyvis = 0.009*lamvis
!=============================================================
      winf(itu1) = 1.5_realtype*uinf2*turbintensityinf**2
      tmp = winf(itu1)/(eddyvisinfratio*nuinf)
      call pushreal8(winf(itu2))
      winf(itu2) = tmp
      call pushcontrol3b(2)
    case (ktau) 
!=============================================================
      winf(itu1) = 1.5_realtype*uinf2*turbintensityinf**2
      tmp0 = eddyvisinfratio*nuinf/winf(itu1)
      call pushreal8(winf(itu2))
      winf(itu2) = tmp0
      call pushcontrol3b(3)
    case (v2f) 
!=============================================================
      winf(itu1) = 1.5_realtype*uinf2*turbintensityinf**2
      tmp1 = 0.09_realtype*winf(itu1)**2/(eddyvisinfratio*nuinf)
      call pushreal8(winf(itu2))
      winf(itu2) = tmp1
      tmp2 = 0.666666_realtype*winf(itu1)
      call pushreal8(winf(itu3))
      winf(itu3) = tmp2
      call pushreal8(winf(itu4))
      winf(itu4) = 0.0_realtype
      call pushcontrol3b(4)
    case default
      call pushcontrol3b(0)
    end select
  else
    call pushcontrol3b(5)
  end if
! set the value of pinfcorr. in case a k-equation is present
! add 2/3 times rho*k.
  pinfcorr = pinf
  if (kpresent) then
    pinfcorr = pinf + two*third*rhoinf*winf(itu1)
    call pushcontrol1b(0)
  else
    call pushcontrol1b(1)
  end if
! compute the free stream total energy.
  ktmp = zero
  if (kpresent) then
    ktmp = winf(itu1)
    call pushcontrol1b(0)
  else
    call pushcontrol1b(1)
  end if
  vinf = zero
  zinf = zero
  call etotarray_b(rhoinf, rhoinfd, uinf, uinfd, vinf, vinfd, zinf, &
&            zinfd, pinfcorr, pinfcorrd, ktmp, ktmpd, winf(irhoe), winfd&
&            (irhoe), kpresent, 1)
  call popcontrol1b(branch)
  if (branch .eq. 0) winfd(itu1) = winfd(itu1) + ktmpd
  call popcontrol1b(branch)
  if (branch .eq. 0) then
    tempd3 = two*third*pinfcorrd
    pinfd = pinfd + pinfcorrd
    rhoinfd = rhoinfd + winf(itu1)*tempd3
    winfd(itu1) = winfd(itu1) + rhoinf*tempd3
    pinfcorrd = 0.0_8
  end if
  pinfd = pinfd + pinfcorrd
  call popcontrol3b(branch)
  if (branch .lt. 3) then
    if (branch .eq. 0) then
      uinf2d = 0.0_8
      nuinfd = 0.0_8
    else if (branch .eq. 1) then
      call sanuknowneddyratio_b(eddyvisinfratio, nuinf, nuinfd, winfd(&
&                         itu1))
      winfd(itu1) = 0.0_8
      uinf2d = 0.0_8
    else
      call popreal8(winf(itu2))
      tmpd = winfd(itu2)
      winfd(itu2) = 0.0_8
      tempd0 = tmpd/(eddyvisinfratio*nuinf)
      winfd(itu1) = winfd(itu1) + tempd0
      nuinfd = -(winf(itu1)*tempd0/nuinf)
      uinf2d = turbintensityinf**2*1.5_realtype*winfd(itu1)
      winfd(itu1) = 0.0_8
    end if
  else if (branch .eq. 3) then
    call popreal8(winf(itu2))
    tmpd0 = winfd(itu2)
    winfd(itu2) = 0.0_8
    tempd1 = eddyvisinfratio*tmpd0/winf(itu1)
    nuinfd = tempd1
    winfd(itu1) = winfd(itu1) - nuinf*tempd1/winf(itu1)
    uinf2d = turbintensityinf**2*1.5_realtype*winfd(itu1)
    winfd(itu1) = 0.0_8
  else if (branch .eq. 4) then
    call popreal8(winf(itu4))
    winfd(itu4) = 0.0_8
    call popreal8(winf(itu3))
    tmpd1 = winfd(itu3)
    winfd(itu3) = 0.0_8
    winfd(itu1) = winfd(itu1) + 0.666666_realtype*tmpd1
    call popreal8(winf(itu2))
    tmpd2 = winfd(itu2)
    winfd(itu2) = 0.0_8
    tempd2 = 0.09_realtype*tmpd2/(eddyvisinfratio*nuinf)
    winfd(itu1) = winfd(itu1) + 2*winf(itu1)*tempd2
    nuinfd = -(winf(itu1)**2*tempd2/nuinf)
    uinf2d = turbintensityinf**2*1.5_realtype*winfd(itu1)
    winfd(itu1) = 0.0_8
  else
    muinfd = 0.0_8
    uinf2d = 0.0_8
    goto 100
  end if
  muinfd = nuinfd/rhoinf
  rhoinfd = rhoinfd - muinf*nuinfd/rhoinf**2
 100 temp = machcoef**2/rhoinf
  tempd = gammainf*pinf*uinf2d/rhoinf
  uinfd = uinfd + veldirfreestream(3)*winfd(ivz)
  veldirfreestreamd(3) = veldirfreestreamd(3) + uinf*winfd(ivz)
  winfd(ivz) = 0.0_8
  uinfd = uinfd + veldirfreestream(2)*winfd(ivy)
  veldirfreestreamd(2) = veldirfreestreamd(2) + uinf*winfd(ivy)
  winfd(ivy) = 0.0_8
  uinfd = uinfd + veldirfreestream(1)*winfd(ivx)
  veldirfreestreamd(1) = veldirfreestreamd(1) + uinf*winfd(ivx)
  winfd(ivx) = 0.0_8
  rhoinfd = rhoinfd + winfd(irho) - temp*tempd
  machcoefd = machcoefd + 2*machcoef*tempd
  gammainfd = gammainfd + temp*pinf*uinf2d
  pinfd = pinfd + temp*gammainf*uinf2d
end subroutine setflowinfinitystate_b
