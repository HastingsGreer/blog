# This file was generated, do not modify it. # hide
py""" #hide
def DQ_AD_solve(D):
    eye = np.eye(len(D))

    def feasible(permutation_so_far):
        if ( np.abs(np.linalg.norm(D[len(permutation_so_far) - 1]) - np.linalg.norm(D[permutation_so_far[-1]])) > 0.001):
            return False
        P = eye[: len(permutation_so_far)]
        PA = eye[permutation_so_far]
        Q, residuals, _rank, _singular_values = np.linalg.lstsq(P@D, PA@D)

        if np.abs(np.linalg.det(Q) + 1) < .001:
            return False

        if len(permutation_so_far) == len(D):
            permutations.append(PA)
            rotations.append(Q)
            return False

        return len(residuals) == 0 or (np.max(np.abs(residuals)) < 0.0001).item()

    def recursive_permutations(permutation_so_far):
        for i in range(len(D)):
            if not i in permutation_so_far:
                continuation = permutation_so_far + [i]
                if feasible(continuation):
                    recursive_permutations(continuation)

    permutations = []
    rotations = []
    recursive_permutations([])
    return permutations, rotations
global_perms, global_rotations = DQ_AD_solve(display_matrix)
[print(np.argmax(perm, axis=0)) for perm in global_perms]
""" #hide
print(String(take!(buf))) #hide
