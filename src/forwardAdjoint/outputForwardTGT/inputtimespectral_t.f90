   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.7 (r4786) - 21 Feb 2013 15:53
   !
   !      ==================================================================
   MODULE INPUTTIMESPECTRAL_T
   USE PRECISION
   IMPLICIT NONE
   SAVE 
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Input parameters for time spectral problems.                   *
   !      *                                                                *
   !      ******************************************************************
   !
   ! nTimeIntervalsSpectral: Number of time instances used.
   INTEGER(kind=inttype) :: ntimeintervalsspectral
   ! dscalar(:,:,:): Matrix for the time derivatices of scalar
   !                 quantities; different for every section to
   !                 allow for different periodic angles.
   !                 The second and third dimension equal the
   !                 number of time intervals.
   ! dvector(:,:,:): Matrices for the time derivatives of vector
   !                 quantities; different for every section to
   !                 allow for different periodic angles and for
   !                 sector periodicity.
   !                 The second and third dimension equal 3 times
   !                 the number of time intervals.
   REAL(kind=realtype), DIMENSION(:, :, :), ALLOCATABLE :: dscalar
   REAL(kind=realtype), DIMENSION(:, :, :), ALLOCATABLE :: dvector
   ! writeUnsteadyRestartSpectral: Whether or not a restart file
   !                               must be written, which is
   !                               capable to do a restart in
   !                               unsteady mode.
   ! dtUnsteadyRestartSpectral:    The corresponding time step.
   REAL(kind=realtype) :: dtunsteadyrestartspectral
   LOGICAL :: writeunsteadyrestartspectral
   ! writeUnsteadyVolSpectral:  Whether or not the corresponding
   !                            unsteady volume solution files
   !                            must be written after the
   !                            computation.
   ! writeUnsteadySurfSpectral: Idem for the surface solution
   !                            files.
   ! nUnsteadySolSpectral:      The corresponding number of
   !                            unsteady solutions to be created.
   INTEGER(kind=inttype) :: nunsteadysolspectral
   LOGICAL :: writeunsteadyvolspectral
   LOGICAL :: writeunsteadysurfspectral
   ! rotMatrixSpectral(:,3,3):  The corresponding rotation matrices
   !                            for the velocity. No rotation
   !                            point is needed, because only the
   !                            velocities need to be transformed.
   !                            The matrix stored is the one used
   !                            when the upper bound of the mode
   !                            number is exceeded; for the lower
   !                            bound the inverse (== transpose)
   !                            must be used. The 1st dimension
   !                            is the number of sections.
   REAL(kind=realtype), DIMENSION(:, :, :), ALLOCATABLE :: &
   &  rotmatrixspectral
   END MODULE INPUTTIMESPECTRAL_T