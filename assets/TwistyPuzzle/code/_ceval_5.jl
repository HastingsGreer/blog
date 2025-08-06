# This file was generated, do not modify it. # hide
py""" #hide
def AD_DQ_solve(D):

    def feasible(prefix):
        PA = np.eye(len(D))[prefix]
        P = np.eye(len(D))[: len(prefix)]
        Q, residuals, _rank, _singular_values = np.linalg.lstsq(P@D, PA@D)

        if np.abs(np.linalg.det(Q) + 1) < .001:
            return False

        if len(prefix) == len(D):
            permutations.append(PA)
            rotations.append(Q)
            return False

        return len(residuals) == 0 or (np.max(np.abs(residuals)) < 0.0001).item()

    def recursive_permutations(prefix):
        for i in range(len(D)):
            if not i in prefix:
                continuation = prefix + [i]
                if feasible(continuation):
                    recursive_permutations(continuation)

    permutations = []
    rotations = []
    recursive_permutations([])
    return permutations, rotations
global_perms, global_rotations = AD_DQ_solve(display_matrix)
[print(np.argmax(perm, axis=0)) for perm in global_perms]
""" #hide
print(String(take!(buf))) #hide
