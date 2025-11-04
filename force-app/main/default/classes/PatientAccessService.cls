public with sharing class PatientAccessService {
    public static Boolean canAccessPatient() {
        Set<String> allowedProfiles = new Set<String>{'System Administrator', 'Doctor'};
        String userProfile = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        return allowedProfiles.contains(userProfile);
    }
}
